## Goals
We want to be able to log in users to our system, and track and analyze their League of Legends profiles to aggregate some basic stats for our users. 

To do this we're going to need to access the [Riot Games API](https://developer.riotgames.com/)

You can see the [docs for League of Legends here](https://developer.riotgames.com/docs/lol), what we're mainly interested in is the routing urls for the different regions, and the different API paths [which are located here](https://developer.riotgames.com/apis)

For this project, we'll need to create a multi-node distributed system, which is connected together with LibCluster, we're going to assume an expectation of handling 2000rps to our nodes handling requests.

Becuase this is a real application, we're going to have to make sure we not only have tests for all of this, but also have metrics using the skills we've learned to add Prometheus and Grafana to our applications.

## User Accounts
To help us track our users, we're going to setup a system, where we can have users that are registered via `email`, you may use any form of authentication you wish, either passwords or some time of One Time Verification Pin like SMS/Email authentication. Once a user is registered, they should have a few actions to `login`, `logout` and `fetch` their own user, as well as `search` for other users as well. The final ability each user will have is to add Riot Summoners to their accounts. 

Each user should have a list of summoners they own (because this isn't verified with Riot, we want to make sure multiple users can own the same summoner), summoners are tracked via 
`SummonerID, Summoner Name, PUUID & Region`

Finally all requests to our app (outside login) should be authenticated, you cannot use this service without first logging in.


## Profile & Match Processing
The point of this app, is to view a status of how each player has done, within their past 30 games. To do this we will need some sort of system to read incoming matches for a user and calculate their last 30 matches and aggregate their statistics into what their average statistics are for that 30 day period. For this project we should aim to just aggregate just the matches a player has played, and the player match stats for the players within those games. 

This also means we'll have an aggregate of all the players that were in the games of the people being actively searched

Because we also want to ensure our nodes serving our users don't crash, however we choose to process this should probably not be on our main node serving requests.

## GraphQL API
For this project, we will need a fair amount of api interfaces:

##### Queries:
You may setup the query structure in any way you choose as long as the functionality is present:
- Fetch other users by name (don't display their emails, that would be bad in production)
- Fetch ourselves (with email)
- Fetch League Accounts for a User
- Fetch League Matches for a User
- Fetch League Matches for a League Profile
- Fetch Last 30 games aggregates for any User

##### Mutations:
You may setup the mutation structure in any way you choose as long as the functionality is present:
- Sign up a user by email
- Log in a user and return a session token
- Log out a user
- Add a summoner to a users profile (make sure this is authenticated)
- Remove a summoner from a users profile

##### Subscriptions:
- We want to be able to listen to a user and if they have any new matches, recieve those via socket
- We want to be able to listen to a League Profile and if they have any new matches, recieve those via socket


### Riot API Details
The RiotAPI has a few quirks, after [generating a developer key](https://developer.riotgames.com/) to use for our project, we're going to need to build some sort of Rate Limiting, to ensure we don't over-request for information. If we do, riot will return 429 (Rate Limit Exceeded), and after a certain amount of 429s, the key becomes blacklisted and can no longer be used. 

To counter this, we need to make sure our access to Riot is Rate Limited and we don't request more than we're allowed. There are many ways to achieve this, but how you do it is up to you.



## Summary
There's quite a few parts to this Final Boss, as it's intended to be a real world replica of how we could in work with a Third-Party API and utilize that as the foundation of our application while taking in new users. To summarize, you will need to complete:

- Communicating with Riot
- Rate Limiting and ensuring our key don't get blacklisted
- User Accounts & Authentication
- Linking Riot Accounts to our Users
- Deciding who to scrape and how
- Fetching League Matches from Riot and storing them
- Aggregating League Matches from riot
- GraphQL API to encapsulate all this functionality
- Tests
- Metrics

**GOTCHA**: One big gotcha, you're not allowed to use ConCache or other Caching Libraries for this project, you may use any form of database connector you wish

Here's a couple of useful Riot APIs that you may want to use:
https://developer.riotgames.com/apis#match-v5
https://developer.riotgames.com/apis#summoner-v4