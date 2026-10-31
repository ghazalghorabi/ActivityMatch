
const {onDocumentCreated, onDocumentUpdated} =
  require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

initializeApp();

const db = getFirestore();

// Notify the host when someone joins an event.
exports.notifyHostOnJoin = onDocumentCreated(
  "events/{eventId}/attendees/{userId}",
  async (event) => {
    const {eventId, userId} = event.params;
    const attendee = event.data?.data();

    if (!attendee) return;

    const eventSnapshot = await db.collection("events").doc(eventId).get();

    if (!eventSnapshot.exists) return;

    const eventData = eventSnapshot.data();
    const hostId = eventData.hostId;

    if (!hostId || hostId === userId) return;

    const attendeeName = attendee.displayName || "Someone";
    const eventTitle = eventData.title || "your event";

    const notificationId = `join_${eventId}_${userId}`;

    await db
      .collection("users")
      .doc(hostId)
      .collection("notifications")
      .doc(notificationId)
      .set({
        type: "event_joined",
        title: "New attendee!",
        message: `${attendeeName} joined ${eventTitle}.`,
        eventId: eventId,
        actorId: userId,
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      });

    logger.info("Host notified about new attendee", {eventId, userId});
  },
);

// Notify attendees when an event is cancelled.
exports.notifyAttendeesOnCancellation = onDocumentUpdated(
  "events/{eventId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    if (before.status === "cancelled" || after.status !== "cancelled") {
      return;
    }

    const eventId = event.params.eventId;
    const eventTitle = after.title || "An event";

    const attendeesSnapshot = await db
      .collection("events")
      .doc(eventId)
      .collection("attendees")
      .get();

    if (attendeesSnapshot.empty) return;

    const writes = attendeesSnapshot.docs.map((attendeeDoc) => {
      const userId = attendeeDoc.id;

      return db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .doc(`cancelled_${eventId}`)
        .set({
          type: "event_cancelled",
          title: "Event cancelled",
          message: `${eventTitle} has been cancelled by the host.`,
          eventId: eventId,
          read: false,
          createdAt: FieldValue.serverTimestamp(),
        });
    });

    await Promise.all(writes);

    logger.info("Attendees notified about cancellation", {
      eventId,
      attendeeCount: attendeesSnapshot.size,
    });
  },
);
