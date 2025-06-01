namespace EntityFramework;

public class Invoice
{
    public int InvoiceID { get; set; }
    public string? InvoiceNumber { get; set; }
    public List<InvoiceProduct> Products { get; set; } = [];
    
    public override string? ToString()
    {
        return $"Invoice {InvoiceNumber}";
    }
}
