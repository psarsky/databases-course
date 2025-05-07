// 1. Find all reservations for a client
use("skiRentalDBv3");

db.reservations.find({
  clientId: ObjectId("60d21b4667d0d8992e610c1e"),
});

// 2. Find all equipment rented by a client
use("skiRentalDBv3");

db.reservations.aggregate([
  { $match: { clientId: ObjectId("60d21b4667d0d8992e610c1e") } },
  { $unwind: "$equipment" },
  {
    $project: {
      _id: 0,
      name: "$equipment.name",
      type: "$equipment.type",
    },
  },
]);

// 3. Add a new reservation
use("skiRentalDBv3");

db.reservations.insertOne({
  clientId: ObjectId("60d21b4667d0d8992e610c1e"),
  clientName: "John Smith",
  equipment: [
    {
      equipmentId: ObjectId("60d21b4667d0d8992e610c1b"),
      name: "Atomic Redster",
      type: "ski",
    },
    {
      equipmentId: ObjectId("60d21b4667d0d8992e610c1d"),
      name: "Head Kore",
      type: "helmet",
    },
  ],
  startDate: new Date("2023-05-10"),
  endDate: new Date("2023-05-15"),
  totalCost: 150.0,
  status: "pending",
});

// 4. Update reservation status
use("skiRentalDBv3");

db.reservations.updateOne(
  { _id: ObjectId("60d21b4667d0d8992e610c24") },
  { $set: { status: "cancelled" } }
);

// 5. Find all reservations for a specific date range
use("skiRentalDBv3");

db.reservations.find({
  startDate: { $gte: new Date("2025-01-01") },
  endDate: { $lte: new Date("2025-01-31") },
});

// 6. Get reservation details
use("skiRentalDBv3");

db.reservations.findOne({ _id: ObjectId("60d21b4667d0d8992e610c24") });

// 7. Count total rentals for each equipment type
use("skiRentalDBv3");

db.reservations.aggregate([
  { $unwind: "$equipment" },
  {
    $group: {
      _id: "$equipment.type",
      count: { $sum: 1 },
    },
  },
]);

// 8. Get revenue summary by month
use("skiRentalDBv3");

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
