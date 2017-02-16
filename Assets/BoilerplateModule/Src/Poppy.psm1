enum MeType
{
    Null
}

class Poppy {
    [String]greetings($moduleName)
    {
        return "Hi, I'm $moduleName"
    }
    
    [String]whoCreatedYou($moduleAuthor)
    {
        return "I was created by $moduleAuthor"
    }
    
    [String]whereCanIFindHim($githubUserName)
    {
        return "Look him on https://github.com/$githubUserName"
    }
    
    [String]whatDoYouThinkAbout($thatGuy)
    {
        return 'Did you say: "{0}" ?' -f $thatGuy
    }
}