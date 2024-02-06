using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class PARMyPartsAndFitment
    {
        public string tenantID { get; set; } = "0";
        public string pageNumber { get; set; } = "1";
        public string ddlItemId { get; set; } = "0";
        public string searchValue { get; set; } = string.Empty;

    }
}
