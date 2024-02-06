using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{
    public class MDLGetErrorFitments
    {
        public string ID { get; set; }
        public string TenantID { get; set; }
        public string PartID { get; set; }
        public string Year { get; set; }
        public string Make { get; set; }
        public string Model { get; set; }
        public string Qty { get; set; }
        public int Total { get; set; }

    }
}
