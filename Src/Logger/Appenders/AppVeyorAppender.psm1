using module ..\ILogger.psm1


class AppVeyorAppender: ILoggerAppender
{
    [void]log([ILoggerEntry]$entry)
    {
        Add-AppveyorMessage $entry.message -Category ([String]$entry.severity)
    }
}