use("skiRentalDBv2");

// Example data for clients collection
db.clients.insertMany([
  {
    _id: ObjectId("60d21b4667d0d8992e610c22"),
    name: "John Smith",
    email: "john.smith@example.com",
    phone: "555-123-4567",
    reservations: [
      {
        equipment: [
          {
            equipmentId: ObjectId("60d21b4667d0d8992e610c1a"),
            name: "Rossignol Experience 76",
            type: "ski",
            size: "170cm",
            dailyRate: 25.0,
          },
          {
            equipmentId: ObjectId("60d21b4667d0d8992e610c1c"),
            name: "Lange XT3",
            type: "boots",
            size: "27.5",
            dailyRate: 15.0,
          },
        ],
        startDate: new Date("2025-01-15"),
        endDate: new Date("2025-01-18"),
        totalCost: 120.0,
        status: "completed",
      },
    ],
  },
  {
    _id: ObjectId("60d21b4667d0d8992e610c23"),
    name: "Sarah Johnson",
    email: "sarah.j@example.com",
    phone: "555-987-6543",
    reservations: [
      {
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
        startDate: new Date("2025-05-10"),
        endDate: new Date("2025-05-12"),
        totalCost: 80.0,
        status: "pending",
      },
    ],
  },
]);
