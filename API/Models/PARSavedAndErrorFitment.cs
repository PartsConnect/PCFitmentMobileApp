using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class PARSavedAndErrorFitment
    {
        public string tenantID { get; set; } = "0";
        public string partID { get; set; } = "0";
        public string pageNumber { get; set; } = "1";
        public string YearSearch { get; set; } = "";
        public string MakeSearch { get; set; } = "";
        public string ModelSearch { get; set; } = "";

    }
}
