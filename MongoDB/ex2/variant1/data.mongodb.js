use("skiRentalDBv1");

// Example data for equipment collection
db.equipment.insertMany([
  {
    _id: ObjectId("60d21b4667d0d8992e610c1a"),
    name: "Rossignol Experience 76",
    type: "ski",
    size: "170cm",
    dailyRate: 25.0,
    isAvailable: true,
  },
  {
    _id: ObjectId("60d21b4667d0d8992e610c1b"),
    name: "Burton Custom",
    type: "snowboard",
    size: "158cm",
    dailyRate: 30.0,
    isAvailable: true,
  },
  {
    _id: ObjectId("60d21b4667d0d8992e610c1c"),
    name: "Lange XT3",
    type: "boots",
    size: "27.5",
    dailyRate: 15.0,
    isAvailable: true,
  },
  {
    _id: ObjectId("60d21b4667d0d8992e610c1d"),
    name: "Smith Vantage",
    type: "helmet",
    size: "M",
    dailyRate: 10.0,
    isAvailable: false,
  },
]);

// Example data for clients collection
db.clients.insertMany([
  {
    _id: ObjectId("60d21b4667d0d8992e610c1e"),
    name: "John Smith",
    email: "john.smith@example.com",
    phone: "555-123-4567",
  },
  {
    _id: ObjectId("60d21b4667d0d8992e610c1f"),
    name: "Sarah Johnson",
    email: "sarah.j@example.com",
    phone: "555-987-6543",
  },
]);

// Example data for reservations collection
db.reservations.insertMany([
  {
    _id: ObjectId("60d21b4667d0d8992e610c20"),
    clientId: ObjectId("60d21b4667d0d8992e610c1e"),
    equipmentIds: [
      ObjectId("60d21b4667d0d8992e610c1a"),
      ObjectId("60d21b4667d0d8992e610c1c"),
    ],
    startDate: new Date("2025-01-15"),
    endDate: new Date("2025-01-18"),
    totalCost: 120.0,
    status: "completed",
  },
  {
    _id: ObjectId("60d21b4667d0d8992e610c21"),
    clientId: ObjectId("60d21b4667d0d8992e610c1f"),
    equipmentIds: [
      ObjectId("60d21b4667d0d8992e610c1b"),
      ObjectId("60d21b4667d0d8992e610c1d"),
    ],
    startDate: new Date("2025-05-10"),
    endDate: new Date("2025-05-12"),
    totalCost: 80.0,
    status: "pending",
  },
]);
