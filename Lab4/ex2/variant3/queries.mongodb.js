// 1. Find all reservations for a client
use("skiRentalDBv3");

db.reservations.find({
  clientId: ObjectId("60d21b4667d0d8992e610c1f"),
});

// 2. Find all equipment rented by a client
use("skiRentalDBv3");

db.reservations.find(
  { clientId: ObjectId("60d21b4667d0d8992e610c1e") },
  { equipment: 1 }
);

// 3. Add a new reservation
use("skiRentalDBv3");

const client = db.clients.findOne({
  _id: ObjectId("60d21b4667d0d8992e610c1e"),
});

const equipment = [
  {
    _id: ObjectId("60d21b4667d0d8992e610c1b"),
    name: "Burton Custom",
    type: "snowboard",
  },
  {
    _id: ObjectId("60d21b4667d0d8992e610c1d"),
    name: "Smith Vantage",
    type: "helmet",
  },
];

db.reservations_hybrid.insertOne({
  clientId: ObjectId("60d21b4667d0d8992e610c1e"),
  clientName: client.name,
  equipment: equipment.map((e) => ({
    equipmentId: e._id,
    name: e.name,
    type: e.type,
  })),
  startDate: new Date("2025-06-01"),
  endDate: new Date("2025-06-03"),
  totalCost: 80.0,
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

db.reservations_hybrid.find({
  startDate: { $gte: new Date("2025-01-01") },
  endDate: { $lte: new Date("2025-01-31") },
});

// 6. Get reservation details
use("skiRentalDBv3");

db.reservations_hybrid.findOne({ _id: ObjectId("60d21b4667d0d8992e610c24") });

// 7. Find all reservations for a specific item
use("skiRentalDBv3");

db.reservations.find({
  "equipment.equipmentId": ObjectId("60d21b4667d0d8992e610c1a"),
});

// 8. Count total rentals for each equipment type
use("skiRentalDBv3");

db.reservations_hybrid.aggregate([
  { $unwind: "$equipment" },
  {
    $group: {
      _id: "$equipment.type",
      count: { $sum: 1 },
    },
  },
]);

// 9. Get revenue summary by month
use("skiRentalDBv3");

db.reservations_hybrid.aggregate([
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
