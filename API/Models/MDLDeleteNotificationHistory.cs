using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLDeleteNotificationHistory
    {
        public string tenantID { get; set; }
        public string NotificationHistoryID { get; set; }
    }
}
