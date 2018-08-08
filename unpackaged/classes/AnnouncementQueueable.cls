public class AnnouncementQueueable implements Queueable
{
    public List<ConnectApi.AnnouncementInput> toPost;

    public void execute(QueueableContext context)
    {
        postAnnouncements(toPost);
    }

    public static void postAnnouncements(List<ConnectApi.AnnouncementInput> announcements)
    {
        while(announcements.size() > 0)
        {
            if (Limits.getDMLStatements() < Limits.getLimitDMLStatements() && !Test.isRunningTest())
            {
                ConnectApi.AnnouncementInput a = announcements.remove(0);
                ConnectApi.Announcements.postAnnouncement('Internal', a);
            }
            else
            {
                AnnouncementQueueable announcementQueuable = new AnnouncementQueueable();
                announcementQueuable.toPost = announcements;
                break;
            }
        }

        if (announcements.size() > 0 && !Test.isRunningTest())
        {
            AnnouncementQueueable q = new AnnouncementQueueable();
            q.toPost = announcements;
            System.enqueueJob(q);
        }
    }
}