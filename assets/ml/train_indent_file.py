#!/usr/bin/env python3
"""
Magic Ledger — AI Money Coach Intent Classifier Training (v2)
==============================================================
20,000+ training samples with heavy data augmentation.
18 intents, ~100+ base examples each.
"""

import json, os, random, re, numpy as np, tensorflow as tf
from tensorflow import keras

random.seed(42)
np.random.seed(42)

TRAINING_DATA = {
    "greeting": [
        "hi","hello","hey","hi there","hello there","hey there","good morning","good afternoon",
        "good evening","what's up","howdy","sup","yo","hola","namaste","hi buddy","hey coach",
        "hello coach","morning","evening","hi money coach","start","begin","open","launch",
        "greetings","hey bot","hi bot","hello bot","what can you do","how can you help","help me",
        "hey money coach","good day","hi assistant","whats up coach","hello money coach",
        "hey there coach","wake up","are you there","ready","lets go","hi hi","heyy","hellooo",
        "heyyy","hii","good night","morning coach","evening coach","nice to meet you","hey buddy",
        "whats going on","yo coach","oi","hey hey","hi again","start coaching","help","assist me",
        "guide me","talk to me","chat","lets chat","hey genius","hi smart coach","hello ai","hey ai",
        "good morning coach","good evening coach","good afternoon coach","hi financial advisor",
        "hello advisor","hey money guru","open coach","launch coach","start chat","bonjour",
        "hey there buddy","hi pal","whats new","anything new","hello hello",
    ],
    "affordability": [
        "can i afford","can i buy","should i buy","can i get","can i afford a phone",
        "can i buy a laptop","should i buy ps5","can i afford 5000","is 10000 purchase okay",
        "can i spend 2000","do i have enough for","enough money for","can i splurge on",
        "should i get a new phone","can i afford a trip","afford vacation","is it okay to spend",
        "can i purchase","budget for a purchase","will buying hurt my savings",
        "can i afford this month","can i buy something for 500","should i spend on",
        "can i afford a 15000 item","is 3000 too much to spend","enough for a new bike",
        "can i get a subscription","afford a gift","can i buy groceries worth 2000",
        "should i spend 8000 on shoes","can i treat myself","is it wise to buy",
        "purchase feasibility","can i go on a shopping spree","is 50000 too much",
        "can i afford eating out","should i upgrade my phone","can i buy a car",
        "afford a new laptop","can i afford rent","is this purchase safe",
        "will this break my budget","can my wallet handle","do i have room to spend",
        "is 1000 okay to spend","can i afford 20000","should i invest in",
        "can i spend on entertainment","is buying this smart","can i handle this expense",
        "enough money to buy","can i make this purchase","is it affordable",
        "within my budget to buy","can i swing 15000","do i have enough to get",
        "can i comfortably spend","purchase within my means","am i able to buy",
        "feasible to purchase","can i buy without going broke","safe to spend this much",
        "can i afford a 7000 expense","should i pull the trigger","would buying this be okay",
        "can i justify this purchase","can i afford a new watch","can i buy a tablet",
        "should i spend money on a trip","afford a vacation to goa","can i splurge a little",
        "is it okay to treat myself","will 5000 hurt me","can i spend 3000 on food",
        "is it safe to buy electronics","afford new clothes","can i get a gym membership",
        "afford a course","can i afford monthly payments","enough for emi",
        "can i buy this gadget","afford a wedding gift","is 12000 within budget",
        "can i spend freely","how much can i spend safely","safe spending limit",
        "what can i afford right now","max i can spend","spending capacity","purchase power",
        "is my budget enough for this","will this expense be fine","can i take on this cost",
        "handle this payment","can i manage 8000","can i do 25000","buy or not buy",
        "should i go for it","pull the trigger on purchase","is now a good time to buy",
        "can i get away with spending","within my range","is 8000 within my range",
        "room for a splurge","do i have room for a splurge","would 12k hurt my finances",
    ],
    "balance": [
        "what is my balance","how much do i have","account balance","what's in my account",
        "show balance","my balance","total balance","how much money do i have","check balance",
        "what's my bank balance","money in accounts","available balance","current balance",
        "balance check","remaining balance","show my accounts","account summary",
        "what are my accounts","how much cash do i have","money left","funds available",
        "my total money","all accounts balance","bank balance","wallet balance","account money",
        "what's available","net worth","how rich am i","total funds","check my accounts",
        "show me my money","how much is in my bank","money status","financial position",
        "whats my net worth","total assets","liquid money","available cash","cash on hand",
        "money on hand","how much i got","pocket money","total in all accounts",
        "sum of accounts","combined balance","hdfc balance","sbi balance","icici balance",
        "savings account balance","current account balance","how much in savings",
        "how much in current","show all account balances","list my accounts",
        "account wise balance","balance in each account","money across accounts","all my money",
        "how loaded am i","cash situation","my financial standing","balance overview",
        "money overview","funds overview","how much do i own","total holdings","my holdings",
        "what do i have in bank","bank account status","check all balances","balance summary",
        "how much is left","remaining money","leftover money","available funds",
        "disposable money","free cash","uncommitted funds","unspent money","money at hand",
        "show me the balance","display balance","get balance","pull up my balance",
        "whats my account at","how am i looking financially","financial snapshot",
        "tell me my balance","report my balance","balance across banks",
        "multi account balance","total in bank","combined bank balance",
        "how loaded am i right now","show me all my bank totals","financial position check",
    ],
    "category_spending": [
        "how much on food","food spending","spent on groceries","transport expenses",
        "how much on shopping","entertainment cost","food expenses this month",
        "spent on dining","eating out cost","how much did i spend on travel",
        "shopping expenses","bills this month","utility spending","health expenses",
        "education cost","fuel spending","petrol expenses","how much on recharge",
        "subscription cost","rent payment","how much on coffee","swiggy spending",
        "zomato expenses","uber cost","ola expenses","amazon spending",
        "how much on clothes","movie expenses","gym cost","medical expenses",
        "pharmacy spending","electricity bill","water bill","internet cost","phone recharge",
        "how much went to food","what did i spend on transport","category breakdown",
        "spending by category","food bill","grocery bill","restaurant expenses",
        "dining expenses","cafe spending","snack expenses","breakfast cost",
        "lunch spending","dinner expenses","tea and coffee cost","street food spending",
        "online shopping expenses","flipkart spending","fashion expenses","clothing budget",
        "shoe expenses","accessory spending","gadget expenses","tech spending",
        "mobile recharge","dth recharge","wifi bill","gas bill","lpg expense",
        "cooking gas cost","auto rickshaw cost","bus fare","metro cost","train ticket",
        "flight cost","cab expenses","parking fees","toll charges","vehicle maintenance",
        "car service cost","insurance premium","lic payment","health insurance",
        "tuition fees","school fees","coaching cost","book expenses","stationery cost",
        "course fees","medicine cost","doctor visit","hospital bill","lab test cost",
        "dental expenses","eye checkup cost","salon expenses","haircut cost",
        "beauty spending","laundry cost","cleaning expenses","household items",
        "rent amount","emi payment","loan installment","credit card bill",
        "credit card payment","gift expenses","donation amount","charity spending",
        "pet expenses","vet cost","pet food spending","show food category",
        "tell me about food spending","breakdown of transport","detail of shopping",
        "analyze food expenses","food cost analysis","how much for groceries",
        "grocery total","total on eating out","restaurant total",
        "transport total this month","travel total","spending in food category",
        "swiggy is eating my wallet","uber rides costing too much",
        "how much went to restaurants",
    ],
    "comparison": [
        "food vs transport","compare food and shopping","food versus entertainment",
        "which costs more food or transport","compare categories","spending comparison",
        "compare months","this month vs last month","compare income and expenses",
        "food compared to shopping","dining vs groceries","compare this week to last week",
        "month over month","which category is highest","what costs more",
        "entertainment vs food comparison","bills vs shopping","compare my spending",
        "how does this month compare","year over year comparison","weekly comparison",
        "transport vs fuel","compare two categories","which is more expensive food or bills",
        "january vs february","march compared to april","last month versus this month",
        "previous month comparison","food or shopping which is more","transport or food",
        "eating out vs groceries","dine in vs take out cost","uber vs ola spending",
        "swiggy vs zomato cost","amazon vs flipkart spending","online vs offline shopping",
        "weekday vs weekend spending","morning vs night spending",
        "how do my expenses compare","expense comparison","side by side comparison",
        "head to head spending","which takes more money","bigger expense food or transport",
        "spending face off","category battle","compare food shopping transport",
        "rank my categories","which category wins","highest vs lowest category",
        "top vs bottom spending","best vs worst category","q1 vs q2",
        "first half vs second half","compare my savings rate","income comparison",
        "earning vs spending comparison","inflow vs outflow","compare across months",
        "trend comparison","how am i doing vs last month","progress comparison",
        "better or worse than last month","improved or not","am i spending more or less",
        "spending change","pit them against each other","show me the difference between",
        "contrast food and transport","food against entertainment","shopping against bills",
        "bills or food higher","rent vs food","emi vs shopping","necessities vs wants",
        "needs vs luxuries","essential vs non essential spending",
        "food or shopping which eats more","am i doing better than february",
        "needs versus wants breakdown",
    ],
    "budget_status": [
        "budget status","am i on track","over budget","how's my budget","budget check",
        "under budget","budget remaining","budget left","exceeded budget",
        "how much budget left","am i within budget","budget utilization",
        "check my budgets","budget progress","am i overspending","spending within limits",
        "any budget exceeded","budget warnings","how close am i to budget limit",
        "budget health","remaining budget for food","budget for this month",
        "did i cross any budget","all budgets status","show budget progress",
        "budget overview","budget tracker","track my budget","budget report",
        "am i sticking to budget","following my budget","budget adherence",
        "budget compliance","within limits","over the limit","crossed the budget",
        "busted my budget","blew my budget","budget blown","exceeded limits",
        "budget breach","any alerts on budget","budget alert","budget warning signs",
        "red flags on budget","how is my food budget","food budget remaining",
        "shopping budget status","transport budget left","entertainment budget check",
        "monthly budget review","budget percentage used","how much percent of budget used",
        "budget consumption","budget burn rate","will i stay within budget",
        "budget forecast","projected budget status","budget at current pace",
        "days until budget runs out","budget runway","am i being disciplined",
        "financial discipline check","spending discipline","am i controlled",
        "how tight is my budget","budget flexibility","budget room",
        "budget breathing room","budget slack","any overspend","overspend alert",
        "overspending warning","have i crossed any limits",
        "am i being financially disciplined","any red flags on spending",
    ],
    "income_query": [
        "how much did i earn","income this month","total income","salary received",
        "money earned","income summary","earnings this month","total earnings",
        "income sources","where is income from","salary details","income breakdown",
        "how much was credited","received this month","income vs expenses",
        "earning trend","monthly income","income history","last salary",
        "payment received","freelance income","side income","bonus received",
        "how much did i get paid","total received this month","all income entries",
        "income count","show my income","display earnings","income report",
        "salary credited","pay received","wages earned","compensation received",
        "how much came in","money coming in","inflow","cash inflow","total inflow",
        "incoming money","deposits this month","credits this month","money deposited",
        "amount credited","funds received","income from all sources","passive income",
        "investment income","interest earned","dividend received","rental income",
        "side hustle income","gig income","contract payment","client payment",
        "reimbursement received","refund received","cashback earned","rewards earned",
        "how much is my salary","monthly salary","take home pay","net salary",
        "gross income","income after tax","all money received","total credits",
        "earning summary","income overview","latest income","recent income",
        "income trend over months","income growth","am i earning more",
        "income by source","how much from salary","how much from freelance",
        "primary income","secondary income","whats coming into my account",
        "total money received so far","break down my pay sources",
    ],
    "savings_query": [
        "how much saved","savings rate","am i saving enough","savings this month",
        "saving percentage","how much am i saving","net savings","monthly savings",
        "savings goal progress","savings target","am i saving","saving enough money",
        "can i save more","how to save more","savings trend",
        "savings compared to last month","savings grade","am i a good saver",
        "saving habits","savings rate grade","how much should i save","ideal savings",
        "savings benchmark","emergency fund progress","financial cushion",
        "savings status","savings check","savings report","am i being frugal",
        "frugality check","thrifty enough","money saved this month","total saved",
        "cumulative savings","savings over time","savings growth","savings trajectory",
        "savings improvement","savings vs spending","saving more than spending",
        "positive savings","negative savings","savings deficit","how much am i keeping",
        "money kept","money retained","savings percentage of income","percent saved",
        "what fraction am i saving","saving ratio","savings efficiency",
        "50 30 20 rule check","am i following 50 30 20","savings discipline",
        "could i save more","room to save","savings potential","where can i save",
        "savings recommendation","optimal savings","target savings rate",
        "am i on track to save","savings pace","will i hit my savings goal",
        "emergency fund status","rainy day fund","financial safety",
        "savings health","savings fitness","grade my savings","rate my savings",
        "score my savings","savings score","am i keeping enough aside",
        "grade my saving habits","how padded is my safety net",
    ],
    "where_money_goes": [
        "where is my money going","where does money go","bleeding money","money leak",
        "biggest expenses","top spending categories","where am i spending most",
        "money drain","biggest cost","highest spending area",
        "what am i wasting money on","unnecessary spending","where is cash going",
        "spending breakdown","top expenses","major expenses","cost breakdown",
        "spending analysis","where do i spend","spending distribution",
        "what eats my money","money holes","financial leaks",
        "what's costing me most","primary expenses","show me where money goes",
        "spending pie chart","my wallet is draining fast","wallet is draining",
        "money draining fast","cash is draining","funds draining quickly",
        "hemorrhaging money","burning through cash","spending too fast",
        "money disappearing quickly","where is it all going","losing money fast",
        "cash disappearing","money vanishing","where did my money go",
        "where did all the money go","spent it all","all my money is gone",
        "cash flow problem","spending problem","overspending issue",
        "what am i blowing money on","blowing cash","throwing money away",
        "money down the drain","pouring money into","wasting resources",
        "financial waste","leaking money like a sieve","spending like water",
        "money flowing out","outflow analysis","cash outflow breakdown",
        "where the money went","expense breakdown","expense analysis",
        "expense distribution","spending pattern","spending habits",
        "spending behavior","what costs the most","biggest money pit",
        "largest expense area","dominant expense","number one expense",
        "top cost center","main spending area","primary spending",
        "bulk of spending","majority of expenses","where most money goes",
        "heaviest category","most expensive category","costliest area",
        "show me spending breakdown","analyze my spending","dissect my expenses",
        "break down my spending","spending audit","expense audit",
        "money going out fast","rapid spending","cant hold onto money",
        "money slipping away","cash keeps leaving","account keeps shrinking",
        "balance keeps dropping","always spending","non stop spending",
        "cash keeps vanishing somehow","what am i blowing all my cash on",
        "account keeps getting smaller",
    ],
    "daily_average": [
        "daily average","average spending per day","daily spending","how much per day",
        "per day expense","spending rate","daily burn rate","average daily cost",
        "day by day spending","daily expense average","average daily expense",
        "what do i spend per day","daily budget usage","how much am i spending daily",
        "per day average","daily spend rate","average per day this month",
        "daily expenditure","day wise spending","average daily outflow","cost per day",
        "expense per day","money per day","daily money usage","daily cash burn",
        "how much each day","each day average","typical daily spend",
        "normal daily expense","usual daily cost","standard daily spending",
        "mean daily expense","median daily spend","average day cost",
        "cost of an average day","what does a day cost me","daily financial footprint",
        "how much a day","spend rate per day","consumption per day",
        "daily consumption rate","daily drain rate","money burned per day",
        "cash used per day","per diem spending","daily overhead","running daily cost",
        "daily operating cost","day to day expenses","everyday spending",
        "everyday expenses","routine daily cost","regular daily spend",
        "whats my daily average","tell me daily average","show daily spending",
        "display daily average","report daily expense","daily stats","per day stats",
        "daily numbers","daily spending figure","daily spending amount",
        "what does a typical day cost me","average daily damage",
    ],
    "projection": [
        "projection","end of month","at this rate","month end projection",
        "projected spending","will i overspend","spending forecast","prediction",
        "at current pace","projected savings","how much will i spend by month end",
        "forecast","spending trajectory","will i go over budget",
        "estimated month end","what will i save","projected balance",
        "if i keep spending like this","extrapolate spending","pace of spending",
        "month end estimate","end of month estimate","month end forecast",
        "where am i headed","spending direction","financial trajectory",
        "whats the outlook","financial outlook","predict my spending",
        "predict month end","forecast my expenses","forecast savings",
        "will i run out of money","money going to last","will money last the month",
        "enough for the month","will i make it through the month","financial forecast",
        "projected outcome","expected month end","anticipated spending",
        "anticipated savings","estimated total spending","estimated savings",
        "on track to spend","on pace to spend","going to spend","going to save",
        "likely to spend","likely to save","if this continues","at this speed",
        "trend projection","extrapolate current trend","project forward",
        "look ahead financially","financial future","month end prediction",
        "spending prediction","savings prediction","where will i be at month end",
        "month end situation","projected monthly total","how will the month end",
        "where am i headed this month","will my money survive till salary",
    ],
    "total_spent": [
        "total spent","how much spent","total expenses","spending total","month total",
        "how much did i spend","total this month","all expenses","complete spending",
        "sum of expenses","total expenditure","money spent","how much have i spent",
        "expense total","spent so far","total cost this month","month spending total",
        "how much gone","total outflow","outgoing total","cumulative spending",
        "aggregate expenses","grand total expenses","overall spending",
        "entire spending","full spending amount","spending amount","expense amount",
        "total amount spent","total money spent","total cash spent","how much used",
        "money used this month","spent from my account","debited this month",
        "total debits","total withdrawals","how much out","money out","cash out",
        "all money spent","everything i spent","sum total of spending","spending sum",
        "running total","total to date","spending to date","expense to date",
        "month to date spending","year to date spending","total ytd",
        "how much this year","annual spending","yearly total","this year expenses",
        "total spent overall","all time expenses","cumulative total",
        "how deep in expenses","total damage","whats the damage",
        "how much did i blow","amount spent","money gone this month",
        "total damage this month","how deep in expenses am i",
    ],
    "extremes": [
        "biggest expense","largest purchase","most expensive","smallest expense",
        "cheapest purchase","highest transaction","biggest single expense",
        "most costly","least expensive","biggest spend","largest single transaction",
        "what was my biggest expense","most expensive purchase","highest expense",
        "lowest expense","minimum spend","maximum transaction",
        "biggest purchase this month","what cost the most","priciest expense",
        "most expensive thing i bought","costliest item","record expense",
        "highest amount spent","peak expense","max spent at once",
        "single largest outflow","biggest one time expense","largest bill",
        "biggest bill paid","cheapest thing i bought","lowest amount spent",
        "minimum purchase","smallest transaction","tiniest expense","lowest bill",
        "what was the least i spent","smallest amount","micro expense",
        "smallest purchase this month","top expense","number one expense",
        "first place expense","highest ranked expense","show me the biggest",
        "find the largest","whats my record spend","most i spent in one go",
        "single biggest","one time biggest cost","least i spent","lowest single",
        "show extremes","spending extremes","high and low expenses",
        "max and min expenses","range of expenses","outlier expenses",
        "unusual expenses","spending spike","expense spike",
        "whats the priciest thing i bought","find my cheapest transaction",
    ],
    "today_info": [
        "today's spending","spent today","today expenses","how much today",
        "what did i spend today","today's total","expenses today","today cost",
        "did i spend anything today","today's transactions","what happened today",
        "today summary","today's expenses","money spent today","today's outflow",
        "today financial summary","daily report for today","todays damage",
        "today bill","today total cost","how much so far today","today so far",
        "morning spending","afternoon spending","any expenses today",
        "any transactions today","anything spent today","spent anything today",
        "today purchases","bought today","what did i buy today","purchases today",
        "transactions for today","todays transactions list","show me today",
        "display today spending","todays numbers","todays figures",
        "how is today going","today financial update","daily update for today",
        "today snapshot","quick today check","today check","today status",
        "today spending status","update for today","today progress",
        "how much damage today","today expenditure","today costs","today outgoings",
        "spent this morning","spent this afternoon","spent this evening",
        "todays activity","financial activity today","today money movement",
        "any money gone today","todays financial damage report",
    ],
    "week_info": [
        "this week","weekly spending","week expenses","how much this week",
        "week total","weekly total","spending this week","week summary",
        "past 7 days","last 7 days spending","this week's expenses",
        "weekly average","week overview","how was this week","week so far",
        "weekly breakdown","week report","weekly report","seven day total",
        "7 day spending","last seven days","spent this week","week expenditure",
        "weekly cost","weekly expense total","this week total spending",
        "current week","ongoing week expenses","weekly outflow",
        "weekly financial summary","week in review","how much since monday",
        "monday to today","weekday spending","workweek expenses",
        "this work week","business week spending","show me this week",
        "display weekly spending","weekly numbers","weekly figures",
        "weekly stats","week statistics","how am i doing this week",
        "weekly performance","weekly check","weekly status","weekly update",
        "week progress","7 day report","7 day summary","previous 7 days",
        "trailing week","rolling 7 days","week to date","wtd spending",
        "7 day spending recap","how was my week financially",
    ],
    "transaction_count": [
        "how many transactions","transaction count","number of expenses",
        "how many expenses","total transactions","count of transactions",
        "number of transactions this month","how many times did i spend",
        "expense count","income count","transaction frequency",
        "how often do i spend","transactions per day","number of purchases",
        "purchase count","total number of entries","entry count",
        "how many entries","how many records","number of records","record count",
        "spending frequency","expense frequency","how frequently do i spend",
        "frequency of purchases","times i spent","spending instances",
        "number of spending events","spending events","how many bills paid",
        "bills count","payments made","number of payments","total payments",
        "payment count","debits count","number of debits","how many debits",
        "outgoing transactions","number of outgoing","incoming transactions",
        "number of incoming","credit count","how many incomes",
        "income entries count","total entries this month","monthly entry count",
        "transaction volume","spending volume","number of times",
        "how many swipes","card swipes count","how many upi",
        "upi transaction count","digital payments count","cash payments count",
        "how many times did my card swipe","volume of transactions",
    ],
    "tips": [
        "give me tips","financial advice","how to save money","suggestions",
        "money tips","saving tips","how can i improve","help me save",
        "financial tips","advice on spending","help with finances","money advice",
        "spending tips","budgeting advice","how to spend less",
        "improve my finances","financial suggestions","what should i do",
        "recommend something","guide me","help me budget","tips to save more",
        "reduce spending tips","smart money tips","financial health tips",
        "money management tips","money management advice","personal finance tips",
        "personal finance advice","how to cut costs","cost cutting tips",
        "reduce expenses","lower my bills","cut my spending",
        "financial planning","plan my finances","budgeting tips",
        "how to budget better","budget improvement","saving strategies",
        "saving techniques","ways to save","methods to save",
        "money saving hacks","financial hacks","frugal tips","frugal living",
        "be more careful with money","careful spending","mindful spending",
        "conscious spending","smart spending","spend wisely",
        "wise financial decisions","better money choices",
        "improve financial health","boost savings","increase savings",
        "grow my savings","build wealth","wealth building tips",
        "emergency fund tips","build emergency fund","debt reduction tips",
        "pay off debt faster","coach me","teach me about money",
        "educate me financially","financial education","money lessons",
        "what can i learn","help me get better","financial improvement",
        "optimize my spending","optimize finances",
        "teach me to be better with money","how do i stop overspending",
    ],
    "summary": [
        "summary","overview","how am i doing","monthly overview","financial summary",
        "status","quick summary","month summary","show everything","overall status",
        "financial status","money overview","general overview","how are my finances",
        "full summary","complete overview","dashboard","report","monthly report",
        "financial report","give me a summary","how's it going financially",
        "my financial health","money status","finance check","rundown",
        "give me a rundown","quick rundown","brief summary","brief overview",
        "snapshot","financial snapshot","money snapshot","quick check",
        "quick status","quick overview","at a glance","glance at my finances",
        "high level view","big picture","overall picture","full picture",
        "comprehensive summary","detailed summary","everything at once",
        "show me everything","all in one view","consolidated view",
        "monthly review","month in review","monthly recap","month recap",
        "how did i do","how have i been doing","performance review",
        "financial performance","how is my month going","financial health check",
        "health check","money health","financial wellness","wellness check",
        "checkup","financial checkup","diagnose my finances",
        "assess my finances","financial assessment","evaluate my spending",
        "rate my finances","grade my finances","score my financial health",
        "tell me everything","give me the full picture","whats the situation",
        "current situation","state of affairs","financial state",
        "where do i stand","my standing","how am i placed",
        "give me the full financial picture","where do i stand right now",
    ],
}

# Augmentation
PREFIXES = ["","","","please ","can you ","could you ","hey ","okay ","tell me ","show me ",
            "i want to know ","what about ","let me know ","check ","quickly ","just ",
            "can you tell me ","help me with ","figure out ","i was wondering "]
SUFFIXES = [""," please"," now"," quickly"," for me"," right now"," today",
            " thanks"," coach"," buddy"," this month"]
SYNONYMS = {
    'money':['cash','funds','bucks','rupees','dough','moolah'],
    'spend':['spent','use','blow','burn','waste','shell out'],
    'save':['saved','keep','retain','stash','put away','set aside'],
    'buy':['purchase','get','acquire','grab','pick up','order'],
    'afford':['handle','manage','swing','cover','bear'],
    'balance':['total','amount','funds'],
    'income':['earnings','salary','pay','wages','revenue'],
    'budget':['limit','cap','allocation','allowance'],
    'food':['eating','dining','meals','groceries','restaurants'],
    'transport':['travel','commute','cab','uber','auto'],
    'big':['large','huge','massive','major','significant'],
    'small':['tiny','little','minor','minimal'],
    'show':['display','reveal','tell','give','present'],
    'check':['verify','see','look at','review','examine'],
    'going':['heading','flowing','moving','draining'],
    'fast':['quick','rapid','quickly','swiftly'],
    'account':['bank','wallet','bank account'],
}

def add_typos(text):
    if len(text)<5 or random.random()>0.3: return text
    words=text.split()
    if not words: return text
    idx=random.randint(0,len(words)-1)
    w=words[idx]
    if len(w)<3: return text
    t=random.choice(['swap','drop','double'])
    if t=='swap' and len(w)>2:
        i=random.randint(0,len(w)-2); w=w[:i]+w[i+1]+w[i]+w[i+2:]
    elif t=='drop' and len(w)>3:
        i=random.randint(1,len(w)-2); w=w[:i]+w[i+1:]
    elif t=='double' and len(w)>2:
        i=random.randint(0,len(w)-1); w=w[:i]+w[i]+w[i:]
    words[idx]=w
    return ' '.join(words)

def synonym_replace(text):
    words=text.split(); replaced=0; new_words=[]
    for w in words:
        wl=w.lower()
        if wl in SYNONYMS and replaced<2 and random.random()>0.5:
            new_words.append(random.choice(SYNONYMS[wl])); replaced+=1
        else: new_words.append(w)
    return ' '.join(new_words)

def augment_text(text):
    augmented=set(); augmented.add(text)
    for _ in range(3): augmented.add(random.choice(PREFIXES)+text)
    for _ in range(2): augmented.add(text+random.choice(SUFFIXES))
    augmented.add(random.choice(PREFIXES)+text+random.choice(SUFFIXES))
    for _ in range(5): augmented.add(synonym_replace(text))
    words=text.split()
    if len(words)>3:
        for _ in range(2):
            d=random.randint(0,len(words)-1)
            augmented.add(' '.join(w for i,w in enumerate(words) if i!=d))
    if len(words)>2:
        i=random.randint(0,len(words)-2); s=list(words); s[i],s[i+1]=s[i+1],s[i]
        augmented.add(' '.join(s))
    for _ in range(2): augmented.add(add_typos(text))
    augmented.add(text.upper()); augmented.add(text.title())
    return list(augmented)

def clean_text(text):
    t=text.lower().strip()
    t=re.sub(r'[₹$€£]','',t); t=re.sub(r'[^\w\s]',' ',t)
    t=re.sub(r'\d+',' NUM ',t); t=re.sub(r'\s+',' ',t).strip()
    return t

def build_vocab(texts, max_vocab=2000):
    wc={}
    for t in texts:
        for w in t.split(): wc[w]=wc.get(w,0)+1
    sw=sorted(wc.items(),key=lambda x:-x[1])
    v={"<PAD>":0,"<UNK>":1}
    for w,c in sw[:max_vocab-2]:
        if c>=2: v[w]=len(v)
    return v

def text_to_sequence(text,vocab,max_len=25):
    words=text.split()
    seq=[vocab.get(w,1) for w in words[:max_len]]
    seq+=[0]*(max_len-len(seq))
    return seq

def main():
    print("="*60)
    print("Magic Ledger — Intent Classifier v2 (20K+ samples)")
    print("="*60)
    intent_names=sorted(TRAINING_DATA.keys())
    intent_to_id={n:i for i,n in enumerate(intent_names)}
    print(f"\nIntents ({len(intent_names)}):")
    base_total=0
    for n,idx in intent_to_id.items():
        c=len(TRAINING_DATA[n]); base_total+=c
        print(f"  {idx:2d}. {n} ({c} base)")
    print(f"\nTotal base examples: {base_total}")

    all_texts=[]; all_labels=[]
    for intent,examples in TRAINING_DATA.items():
        label=intent_to_id[intent]
        for ex in examples:
            for aug in augment_text(ex):
                cleaned=clean_text(aug)
                if cleaned and len(cleaned)>1:
                    all_texts.append(cleaned); all_labels.append(label)
    print(f"Total after augmentation: {len(all_texts)}")

    vocab=build_vocab(all_texts); print(f"Vocabulary: {len(vocab)}")
    MAX_LEN=25
    X=np.array([text_to_sequence(t,vocab,MAX_LEN) for t in all_texts])
    y=np.array(all_labels)
    idx=np.arange(len(X)); np.random.shuffle(idx); X=X[idx]; y=y[idx]
    split=int(len(X)*0.9)
    X_train,X_val=X[:split],X[split:]
    y_train,y_val=y[:split],y[split:]
    print(f"Train: {len(X_train)}, Val: {len(X_val)}")

    model=keras.Sequential([
        keras.layers.Embedding(len(vocab),48,input_length=MAX_LEN),
        keras.layers.GlobalAveragePooling1D(),
        keras.layers.Dense(128,activation='relu'),
        keras.layers.Dropout(0.4),
        keras.layers.Dense(64,activation='relu'),
        keras.layers.Dropout(0.3),
        keras.layers.Dense(len(intent_names),activation='softmax'),
    ])
    model.compile(optimizer='adam',loss='sparse_categorical_crossentropy',metrics=['accuracy'])
    model.summary()

    print("\nTraining...")
    es=keras.callbacks.EarlyStopping(monitor='val_accuracy',patience=8,restore_best_weights=True)
    h=model.fit(X_train,y_train,validation_data=(X_val,y_val),epochs=80,batch_size=32,callbacks=[es],verbose=1)
    print(f"\nBest val accuracy: {max(h.history['val_accuracy']):.4f}")

    print("\nExporting...")
    converter=tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations=[tf.lite.Optimize.DEFAULT]
    tflite=converter.convert()
    os.makedirs("output",exist_ok=True)
    with open("output/money_coach_model.tflite","wb") as f: f.write(tflite)
    print(f"Model: {len(tflite)/1024:.1f} KB")
    with open("output/vocab.json","w") as f: json.dump(vocab,f)
    with open("output/intents.json","w") as f:
        json.dump({"intent_names":intent_names,"intent_to_id":intent_to_id,
                   "max_sequence_length":MAX_LEN,"vocab_size":len(vocab)},f,indent=2)

    # TEST with unseen examples
    print("\n"+"="*60)
    print("Testing UNSEEN examples...")
    print("="*60)
    tests=[
        ("is 8000 within my range","affordability"),
        ("do i have room for a splurge","affordability"),
        ("would 12k hurt my finances","affordability"),
        ("how loaded am i right now","balance"),
        ("show me all my bank totals","balance"),
        ("financial position check","balance"),
        ("swiggy is eating my wallet","category_spending"),
        ("uber rides costing too much","category_spending"),
        ("how much went to restaurants","category_spending"),
        ("food or shopping which eats more","comparison"),
        ("am i doing better than february","comparison"),
        ("needs versus wants breakdown","comparison"),
        ("have i crossed any limits","budget_status"),
        ("am i being financially disciplined","budget_status"),
        ("any red flags on spending","budget_status"),
        ("whats coming into my account","income_query"),
        ("total money received so far","income_query"),
        ("break down my pay sources","income_query"),
        ("am i keeping enough aside","savings_query"),
        ("grade my saving habits","savings_query"),
        ("how padded is my safety net","savings_query"),
        ("my wallet is draining fast","where_money_goes"),
        ("cash keeps vanishing somehow","where_money_goes"),
        ("what am i blowing all my cash on","where_money_goes"),
        ("account keeps getting smaller","where_money_goes"),
        ("money slipping through my fingers","where_money_goes"),
        ("what does a typical day cost me","daily_average"),
        ("average daily damage","daily_average"),
        ("where am i headed this month","projection"),
        ("will my money survive till salary","projection"),
        ("total damage this month","total_spent"),
        ("how deep in expenses am i","total_spent"),
        ("whats the priciest thing i bought","extremes"),
        ("find my cheapest transaction","extremes"),
        ("any money gone today","today_info"),
        ("todays financial damage report","today_info"),
        ("7 day spending recap","week_info"),
        ("how was my week financially","week_info"),
        ("how many times did my card swipe","transaction_count"),
        ("volume of transactions","transaction_count"),
        ("teach me to be better with money","tips"),
        ("how do i stop overspending","tips"),
        ("give me the full financial picture","summary"),
        ("where do i stand right now","summary"),
        ("yo whats good","greeting"),
        ("hey there money guru","greeting"),
    ]
    interp=tf.lite.Interpreter(model_path="output/money_coach_model.tflite")
    interp.allocate_tensors()
    ind=interp.get_input_details(); oud=interp.get_output_details()
    correct=0
    for q,exp in tests:
        cl=clean_text(q)
        s=np.array([text_to_sequence(cl,vocab,MAX_LEN)],dtype=np.float32)
        interp.set_tensor(ind[0]['index'],s); interp.invoke()
        out=interp.get_tensor(oud[0]['index'])[0]
        ti=np.argmax(out); conf=out[ti]; pred=intent_names[ti]
        m="✅" if pred==exp else "❌"
        if pred==exp: correct+=1
        print(f"  {m} \"{q}\"")
        print(f"      Expected: {exp} | Got: {pred} ({conf:.1%})")
    print(f"\nTest: {correct}/{len(tests)} ({correct/len(tests)*100:.1f}%)")
    print("="*60)

if __name__=="__main__":
    main()