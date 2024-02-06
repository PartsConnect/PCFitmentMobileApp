using System;
using System.ComponentModel.DataAnnotations.Schema;
using TestRestAPI.Models.Utilities;

namespace PCFitment_API.Models
{
    public class MDLGetNotificationHistory
    {
        public string App_NotificationHistoryID {  get; set; }
        public string Notification_Type { get; set; }
        public string TenantID { get; set; }
        public string NotificationTitle { get; set; }
        public string NotificationMessage { get; set; }
        public string CreateDate { get; set; }
        public string LinkPage { get; set; }
        public string IsNotificationSent { get; set; }

    }
}
