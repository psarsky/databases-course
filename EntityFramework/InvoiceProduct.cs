namespace EntityFramework;

public class InvoiceProduct
{
    public int InvoiceID { get; set; }
    public int ProductID { get; set; }
    public Invoice? Invoice { get; set; }
    
    public Product? Product { get; set; }
    
    public int Quantity { get; set; }
    
    public override string? ToString()
    {
        return $"{Product?.ProductName} - {Quantity} pcs";
    }
}
