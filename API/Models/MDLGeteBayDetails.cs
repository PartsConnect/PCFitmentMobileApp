using PartsConnectWebTools.Models.Custom;
using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{
    public class MDLGeteBayDetails
    {
        public string ebaylimitreach { get; set; } = string.Empty;
        public string RedirectToAction { get; set; } = string.Empty;
        public string IsAvailableeBayFitment { get; set; } = string.Empty;
        public string msg { get; set; } = string.Empty;
        public string displaymsg { get; set; } = string.Empty;
        public string IsPendingReq { get; set; } = string.Empty;
        public string LastSubmitError { get; set; } = string.Empty;
        public IEnumerable<PartDisplay> SKUlist { get; set; }

    }
}
