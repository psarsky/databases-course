// 1. Find all reservations for a client
use("skiRentalDBv2");

db.clients.findOne(
  { _id: ObjectId("60d21b4667d0d8992e610c22") },
  { reservations: 1 }
);

// 2. Find all equipment rented by a client
use("skiRentalDBv2");

db.clients.aggregate([
  { $match: { _id: ObjectId("60d21b4667d0d8992e610c22") } },
  { $unwind: "$reservations" },
  { $unwind: "$reservations.equipment" },
  {
    $project: {
      _id: 0,
      name: "$reservations.equipment.name",
      type: "$reservations.equipment.type",
      size: "$reservations.equipment.size",
    },
  },
]);

// 3. Add a new reservation
use("skiRentalDBv2");

db.clients.updateOne(
  { _id: ObjectId("60d21b4667d0d8992e610c22") },
  {
    $push: {
      reservations: {
        equipment: [
          {
            equipmentId: ObjectId("60d21b4667d0d8992e610c1b"),
            name: "Burton Custom",
            type: "snowboard",
            size: "158cm",
            dailyRate: 30.0,
          },
          {
            equipmentId: ObjectId("60d21b4667d0d8992e610c1d"),
            name: "Smith Vantage",
            type: "helmet",
            size: "M",
            dailyRate: 10.0,
          },
        ],
        startDate: new Date("2025-06-01"),
        endDate: new Date("2025-06-03"),
        totalCost: 80.0,
        status: "pending",
      },
    },
  }
);

// 4. Update reservation status
use("skiRentalDBv2");

db.clients.updateOne(
  {
    _id: ObjectId("60d21b4667d0d8992e610c22"),
    "reservations.startDate": new Date("2025-01-15"),
  },
  {
    $set: { "reservations.$.status": "cancelled" },
  }
);

// 5. Find all reservations for a specific date range
use("skiRentalDBv2");

db.clients.aggregate([
  { $unwind: "$reservations" },
  {
    $match: {
      "reservations.startDate": { $gte: new Date("2025-01-01") },
      "reservations.endDate": { $lte: new Date("2025-01-31") },
    },
  },
  {
    $project: {
      name: 1,
      email: 1,
      reservations: 1,
    },
  },
]);

// 6. Get reservation details
use("skiRentalDBv2");

db.clients.aggregate([
  { $match: { _id: ObjectId("60d21b4667d0d8992e610c22") } },
  { $unwind: "$reservations" },
  { $match: { "reservations.startDate": new Date("2025-01-15") } },
  {
    $project: {
      _id: 0,
      name: 1,
      email: 1,
      phone: 1,
      reservation: "$reservations",
    },
  },
]);

// 7. Count total rentals for each equipment type
use("skiRentalDBv2");

db.clients.aggregate([
  { $unwind: "$reservations" },
  { $unwind: "$reservations.equipment" },
  {
    $group: {
      _id: "$reservations.equipment.type",
      count: { $sum: 1 },
    },
  },
]);

// 8. Get revenue summary by month
use("skiRentalDBv2");

db.clients.aggregate([
  { $unwind: "$reservations" },
  {
    $project: {
      month: { $month: "$reservations.startDate" },
      year: { $year: "$reservations.startDate" },
      totalCost: "$reservations.totalCost",
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
