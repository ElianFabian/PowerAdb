using System;
using System.Management.Automation;

public class PowerAdbException : RuntimeException
{
    public PowerAdbException(string message) : base(message)
    {
    }

    public PowerAdbException(string message, Exception innerException) : base(message, innerException)
    {
    }
}

public class ApiLevelException : PowerAdbException
{
    public ApiLevelException(string message) : base(message)
    {
    }
}

public class AdbException : PowerAdbException
{
    public AdbException(string message) : base(message)
    {
    }

    public AdbException(string message, Exception innerException) : base(message, innerException)
    {
    }
}

public class AdbCommandException : AdbException
{
    public readonly string Command;

    public AdbCommandException(string message, string command) : base(message)
    {
        Command = command;
    }

    public AdbCommandException(string message, Exception innerException, string command) : base(message, innerException)
    {
        Command = command;
    }
}
