context {
    input endpoint: string;
    input family: string[];
}

// declare external functions here 
external function confirm(fruit: string): boolean;
external function status(): string;

start node root {
    do {
        #connectSafe($endpoint);
        #waitForSpeech(1000);
        #sayText("Hello, welcome to Remory, I will be your personal memory assistant");
        #sayText("Are you ready to store some new memories?");
        wait *;
    }
    transitions { 
        next: goto status on true;
    }
}
digression status{
    conditions { on #messageHasIntent("status"); }
    do{
        goto status;
    }
    transitions{status:goto status;}
}
// acknowledge flow begins 
node status {
  //  conditions { on #messageHasIntent("status"); }
    do {
        #sayText("Great! Now we can get started, what kind of memory would you like to remember? .");
        #sayText("You can choose between things that are family, medical, location related, as well as general information");
        #sayText("Which category would you like to choose?");
        wait *;
    } 
    transitions {
        family: goto family on #messageHasIntent("family");
        son: goto son on #messageHasData("son");
        sonaddress: goto sonaddress on #messageHasData("sonaddress");
    }
}
node family {
    do {
        var family = #messageGetData("family", {value: true})[0]?.value??"";
        #sayText("Within family, what would you like to save?");
        wait *;
    }
    transitions {
        son: goto son on #messageHasIntent("son");
        sonaddress: goto sonaddress on #messageHasIntent("sonaddress");
    }
}

node son {
    do {
        var son = #messageGetData("son", {value: true})[0]?.value??"";
        #sayText("Got it, what would you like to tell me about your son? Name or the address?");
        wait *;
    }
    transitions {
        sonname: goto sonname on #messageHasIntent("sonname");
        sonaddress: goto sonaddress on #messageHasIntent("address");
    }
}
node sonname {
    do {
        var son = #messageGetData("son", {value: true})[0]?.value??"";
        #sayText("What is the name of your son?");
        wait *;
    }
    transitions {
        sonaddress: goto sonaddress on #messageHasIntent("sonname");
        bye_then: goto bye_then on #messageHasIntent("no");
    }
}

node sonaddress {
    do {
        var address = #messageGetData("address", {value: true})[0]?.value??"";
        #sayText("What is the address of your son?");
        wait *;
    }
    transitions {
        can_help: goto can_help on #messageHasIntent("sonaddress");
        bye_then: goto bye_then on #messageHasIntent("no");
    }
}

node confirm {
    do {
        var fruit = #messageGetData("fruit", { value: true })[0]?.value??"";
        var response = external confirm(fruit);
        if (response) {
            #sayText("Great, identity confirmed. Let me just check your status.");
            goto approved;
        }
        else {
            #sayText("I'm sorry but your identity is not confirmed. Let's try again. What is your favourite fruit?");
            wait *;
        }
    } 
    transitions
    {
        approved: goto approved;
        confirm: goto confirm on #messageHasData("fruit");
    }
}

node approved {
    do{
        var status = external status();
        #sayText(status);
        #sayText("Anything else I can help you with today?");
        wait *;
    } 
    transitions
    {
        can_help: goto can_help on #messageHasIntent("yes");
        bye_then: goto bye_then on #messageHasIntent("no");
    }
}

node bye_then {
    do {
        #sayText("Thank you and I hope to hear from you again soon!");
        exit;
    }
}


node can_help {
    do {
        #sayText("Right. I got that down and it will be available for future reference.");
        #sayText("You can tell me what you want to do next, or you can say no to exit");
        wait*;
    }
    transitions {
        son: goto son on #messageHasData("son");
        address: goto sonaddress on #messageHasData("sonaddress");
        bye_then: goto bye_then on #messageHasIntent("no");
    }
}


digression bye  {
    conditions { on #messageHasIntent("bye"); }
    do {
        #sayText("Thank you and happy trails! ");
        exit;
    }
}




// additional digressions 
digression @wait {
    conditions { on #messageHasAnyIntent(digression.@wait.triggers)  priority 900; }
    var triggers = ["wait", "wait_for_another_person"];
    var responses: Phrases[] = ["i_will_wait"];
    do {
        for (var item in digression.@wait.responses) {
            #say(item, repeatMode: "ignore");
        }
        #waitingMode(duration: 70000);
        return;
    }
    transitions {
    }
}

digression repeat {
    conditions { on #messageHasIntent("repeat"); }
    do {
        #repeat();
        return;
    }
} 
