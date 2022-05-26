(* ::Package:: *)

ClearAll["Global`*"]

(* voting website *)
website = "https://foo.com/bar";
browser = "Firefox";

(* maximum number of runs/votes *)
nRuns = 2000;
(* number of first names to select from *)
numFirsts = 1000;
(* number of last names to select from *)
numLasts = 1000;

(* Get an unformatted list of all available VPN locations using mullvad vpn *)
mulInputTxt = 
  StringSplit[RunProcess[{"mullvad" , "relay", "list"}][[2]]];
  
(* format the text returned from mulInputTxt for use in script *)
svrs =
  Reverse@Table[
    If[
     StringMatchQ[mulInputTxt[[iMul]], "*-*-*"],
     StringSplit[mulInputTxt[[iMul]], "-"],
     Nothing,
     Nothing],
    {iMul, Length[mulInputTxt]}];

(* function to return command line options for each available vpn server \
   Input:  iSvr  (int) incremental number for server *)
servFun[iSvr_] :=
 servFun[iSvr] =
  {ToString[svrs[[iSvr]][[1]]],
   ToString[svrs[[iSvr]][[2]]],
   ToString[svrs[[iSvr]][[1]]] <> "-" <> ToString[svrs[[iSvr]][[2]]] <>
     "-" <> ToString[svrs[[iSvr]][[3]]]}

(* Have Mathematica give the most popular first and last names *)
firstNames = 
  EntityClass["GivenName", "Rank" -> TakeSmallest[numFirsts]] // 
   EntityList;
lastNames = 
  EntityClass["Surname", "Rank" -> TakeSmallest[numLasts]] // 
   EntityList;
   
(* Select from the above lists of names at random *)
fName := 
 ToString@firstNames[[RandomInteger[{1, numFirsts}]]][[2]][[1]]
lName := ToString@lastNames[[RandomInteger[{1, numFirsts}]]][[2]]

randomWord := RandomWord[]
randomInt := ToString[RandomInteger[{0, 9}]]

(* create a random gmail address of the consisting of two random \
words and for random integers *)
randomEmail := 
 randomWord <> randomWord <> randomInt <> randomInt <> randomInt <> 
  randomInt <> "@gmail.com"
  
(* It is possible to vote by clicking on the photo or the text *)
(* randomAnd randomly chooses between these two options*)
randomAnd := RandomInteger[{1, 2}]


ParallelDo[
 (* Select mullvad vpn server *)
 RunProcess[{
   "mullvad",
    "relay",
    "set",
    "location",
   servFun[iSvr][[1]],
   servFun[iSvr][[2]],
   servFun[iSvr][[3]]}];
 (* Connect to selected mullvad vpn server *) 
 RunProcess[{"mullvad", "connect"}];
 (* Start Firefox web browser
   Note: Here we specifically used a new session of firefox for each \
    vote, configured to delete all cookies upon closing firefox in order to \
    prevent being tracked via cookie *)
 session = StartWebSession[browser];
 (* Open up voting website *) 
 WebExecute[session, "OpenPage" -> website];
 (* Here we locate and click on desired element based on html tags. 
 This section had to be adjusted specifically based on layout of website *) 
 wbElems = WebExecute["LocateElements" -> "Tag" -> "div"] ;
 posOfNumber = Flatten[
     Position[WebExecute["ElementText" -> wbElems], 
      "Vote"]][[randomAnd]] // Quiet;
 WebExecute[session, "ClickElement" -> wbElems[[posOfNumber]]];
 (* Enter a random first and last name and random email defined above *) 
 allIns = WebExecute["LocateElements" -> "Tag" -> "input"];
 WebExecute[session, "TypeElement" -> {allIns[[1]], fName}];
 WebExecute[session, "TypeElement" -> {allIns[[2]], lName}];
 WebExecute[session, "TypeElement" -> {allIns[[3]], randomEmail}];
 (* Click enter *)
 WebExecute[session, "ClickElement" -> allIns[[4]]];
 (* Close browser session *)
 DeleteObject[session],
 {iSvr, Length[svrs]}]
