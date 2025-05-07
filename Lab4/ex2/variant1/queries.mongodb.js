// 1. Find all reservations for a client
use("skiRentalDBv1");

db.reservations.find({
  clientId: ObjectId("60d21b4667d0d8992e610c1e"),
});

// 2. Find all equipment rented by a client
use("skiRentalDBv1");

db.reservations.aggregate([
  { $match: { clientId: ObjectId("60d21b4667d0d8992e610c1e") } },
  {
    $lookup: {
      from: "equipment",
      localField: "equipmentIds",
      foreignField: "_id",
      as: "equipment",
    },
  },
  { $unwind: "$equipment" },
  {
    $project: {
      _id: 0,
      name: "$equipment.name",
      type: "$equipment.type",
      size: "$equipment.size",
    },
  },
]);

// 3. Add a new reservation
use("skiRentalDBv1");

db.reservations.insertOne({
  clientId: ObjectId("60d21b4667d0d8992e610c1e"),
  equipmentIds: [
    ObjectId("60d21b4667d0d8992e610c1b"),
    ObjectId("60d21b4667d0d8992e610c1d"),
  ],
  startDate: new Date("2025-06-01"),
  endDate: new Date("2025-06-03"),
  totalCost: 80.0,
  status: "pending",
});

// 4. Update reservation status
use("skiRentalDBv1");

db.reservations.updateOne(
  { _id: ObjectId("60d21b4667d0d8992e610c20") },
  { $set: { status: "cancelled" } }
);

// 5. Find all reservations for a specific date range
use("skiRentalDBv1");

db.reservations.find({
  startDate: { $gte: new Date("2025-01-01") },
  endDate: { $lte: new Date("2025-01-31") },
});

// 6. Get reservation details
use("skiRentalDBv1");

db.reservations.aggregate([
  {
    $match: { _id: ObjectId("60d21b4667d0d8992e610c20") },
  },
  {
    $lookup: {
      from: "clients",
      localField: "clientId",
      foreignField: "_id",
      as: "client",
    },
  },
  {
    $unwind: "$client",
  },
  {
    $lookup: {
      from: "equipment",
      localField: "equipmentIds",
      foreignField: "_id",
      as: "equipment",
    },
  },
]);

// 7. Count total rentals for each equipment type
use("skiRentalDBv1");

db.reservations.aggregate([
  { $unwind: "$equipmentIds" },
  {
    $lookup: {
      from: "equipment",
      localField: "equipmentIds",
      foreignField: "_id",
      as: "equipment",
    },
  },
  { $unwind: "$equipment" },
  {
    $group: {
      _id: "$equipment.type",
      count: { $sum: 1 },
    },
  },
]);

// 8. Get revenue summary by month
use("skiRentalDBv1");

db.reservations.aggregate([
  {
    $project: {
      month: { $month: "$startDate" },
      year: { $year: "$startDate" },
      totalCost: 1,
    },
  },
  {
    $group: {
      _id: { month: "$month", year: "$year" },
      totalRevenue: { $sum: "$totalCost" },
    },
  },
  {
    $sort: { "_id.year": 1, "_id.month": 1 },
  },
]);

// 9. Update equipment availability
use("skiRentalDBv1");

db.equipment.updateOne(
  { _id: ObjectId("60d21b4667d0d8992e610c1a") },
  { $set: { isAvailable: false } }
);
