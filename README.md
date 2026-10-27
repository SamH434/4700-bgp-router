# Project 3: BGP Router

Basic BGP router written in Python (built on top of the provided starter code)

## How to run

```
./4700router <asn> <port-ip-relation> [<port-ip-relation> ...]
```

Example: `./4700router 7 7833-1.2.3.2-cust 7834-5.6.7.2-peer`

## High-level approach

The router keeps one UDP socket for each neighbor and uses `select()` in a single loop to read from whichever socket has data. Each message is decoded from JSON and passed to a handler based on its `type`

- **update**: the full announcement (including localpref, selfOrigin, ASPath, origin and the neighbor it came from) is saved to a list of routes and the forwarding table is then rebuilt. A copy of the update is sent on to other neighbors with our ASN added to the front of the ASPath.
- **withdraw**: any saved routes that match the network/netmask and came from that same neighbor are removed, the table is rebuilt and the withdraw is passed on.
- **data**: the router finds the best matching route. It first looks for the longest prefix match, then breaks ties using highest localpref, selfOrigin true, shortest ASPath, best origin, and lowest neighbor IP. The packet is forwarded only if the sender or the next hop is a customer. Otherwise (or if no route exists) a "no route" message goes back to the sender.
- **dump**: the router replies with a "table" message containing the current (aggregated) forwarding table.

Updates and withdraws follow the relationship rules that routes from a customer are sent to all other neighbors, while routes from a peer or provider are only sent to customers.

### IP address handling

The `ipaddress` module is not used. IP addresses and netmasks are converted to 32 bit integers with bit shifting, and matching is done with bitwise AND. Prefix length is the number of 1 bits in the netmask.

## Challenges

- Getting the tie breaking order right. selfOrigin has to be checked before ASPath length, not after.
- At first only one route per network was stored, so a second announcement for the same network from a different neighbor overwrote the first. Storing every announcement in a list fixed this
- Remembering to strip the private fields (localpref, selfOrigin, origin) and to put our ASN at the front of the ASPath when passing updates on
- Disaggregation after a withdraw. Rebuilding the whole table from the saved routes was much simpler than trying to split aggregated entries back apart

## Testing

The router was tested with the provided simulator. 

Single configs were run with `./run configs/<file>.conf` while debugging.

Full suite with `./test`. All 17 provided test configurations pass.