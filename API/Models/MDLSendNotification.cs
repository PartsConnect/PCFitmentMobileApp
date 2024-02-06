using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLSendNotification
    {
        public string Notification_Type { get; set; } = "Custom";
        public string TenantID { get; set; }
        public string NotificationTitle { get; set; }
        public string NotificationMessage { get; set; }
        public string NotificationDate { get; set; }
    }
}
