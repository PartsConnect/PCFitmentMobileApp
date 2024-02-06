using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetMyPartsAndFitmentDetails
    {
        public string partnum { get; set; }
        public string PartType { get; set; }
        public string ASIN { get; set; }
        public string BrandID { get; set; }
        public string ManufactureLabel { get; set; }
        public string PartDescription { get; set; }
        public string Fitmentsnum { get; set; }

    }
}
