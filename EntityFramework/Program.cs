class Program
{
    static void Main()
    {
        var dbContext = new ProdContext();
        var newProduct = GetProductDetails();

        bool addedNewSupplier = SupplierSelection(dbContext, out Supplier? selectedSupplier);

        Console.WriteLine("Adding product to supplier...");
        if (selectedSupplier != null)
        {
            selectedSupplier.Products.Add(newProduct);
            newProduct.Supplier = selectedSupplier;
        }

        Console.WriteLine("Saving data...");
        SaveToDatabase(dbContext, newProduct, selectedSupplier, addedNewSupplier);
    }
    
    private static bool SupplierSelection(ProdContext db, out Supplier? selectedSupplier)
    {
        bool createdNew = false;
        
        while (true)
        {
            Console.WriteLine("Do you want to add a new supplier? (y/n; default: n)");
            var response = Console.ReadLine()?.ToLower() ?? "";
            
            if (response == "y")
            {
                selectedSupplier = GetSupplierDetails();
                createdNew = true;
                break;
            }
            else if (response == "n" || response == "")
            {
                ShowSuppliers(db);
                selectedSupplier = SelectExistingSupplier(db);
                break;
            }
        }
        
        return createdNew;
    }
    
    private static void SaveToDatabase(ProdContext db, Product product, Supplier? supplier, bool isNewSupplier)
    {
        if (isNewSupplier && supplier != null)
        {
            db.Suppliers.Add(supplier);
        }
        db.Products.Add(product);
        db.SaveChanges();
    }
    
    private static Product GetProductDetails()
    {
        Console.Write("Enter product name\n>>> ");
        string name = Console.ReadLine() ?? "";
        
        int stock;
        string input;
        do
        {
            Console.Write("Enter number of items in stock\n>>> ");
            input = Console.ReadLine() ?? "";
        } while (string.IsNullOrEmpty(input) || !int.TryParse(input, out stock));
        
        Console.WriteLine("Creating new product...");
        var newProduct = new Product
        {
            ProductName = name,
            UnitsInStock = stock
        };
        
        Console.WriteLine($"Created product: {newProduct}");
        return newProduct;
    }
    
    private static Supplier GetSupplierDetails()
    {
        Console.Write("\nEnter supplier name\n>>> ");
        string name = Console.ReadLine() ?? "";
        
        Console.Write("Enter city name\n>>> ");
        string city = Console.ReadLine() ?? "";
        
        Console.Write("Enter street name\n>>> ");
        string street = Console.ReadLine() ?? "";
        
        Console.WriteLine("Creating new supplier...");
        var newSupplier = new Supplier
        {
            CompanyName = name,
            City = city,
            Street = street
        };
        
        Console.WriteLine($"Created supplier: {newSupplier}");
        return newSupplier;
    }
    
    private static Supplier? SelectExistingSupplier(ProdContext db)
    {
        int supplierId = 0;
        string input;
        
        do
        {
            Console.Write("Enter shipper ID for the new product\n>>> ");
            input = Console.ReadLine() ?? "";
        } while (string.IsNullOrEmpty(input) || !int.TryParse(input, out supplierId));
        
        return db.Suppliers
            .Where(s => s.SupplierID == supplierId)
            .FirstOrDefault();
    }
    
    private static void ShowSuppliers(ProdContext db)
    {
        Console.WriteLine("Supplier list:");
        foreach (var supplier in db.Suppliers)
        {
            Console.WriteLine($"[{supplier.SupplierID}] {supplier}");
        }
    }
}