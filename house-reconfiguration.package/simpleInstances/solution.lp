%%%%%%%%%%%%%%%%%%%
% File: solution.lp
%%%%%%%%%%%%%%%%%%%
% Include all cabinets in the cabinet domain, whether new or legacy
cabinetDomain(C) :- cabinetDomainNew(C).
cabinetDomain(C) :- legacyConfig(cabinet(C)).

% Include all rooms in the room domain, whether new or legacy
roomDomain(R) :- roomDomainNew(R).
roomDomain(R) :- legacyConfig(room(R)).

% Assign cabinets and rooms from their respective domains
{ cabinet(C) } :- cabinetDomain(C).
{ room(R) } :- roomDomain(R).

% Symmetry-breaking rule to enforce ordering for new rooms and cabinets
room(R1) :- roomDomainNew(R1), roomDomainNew(R2), room(R2), R1 < R2.
cabinet(C1) :- cabinetDomainNew(C1), cabinetDomainNew(C2), cabinet(C2), C1 < C2.

% Each thing must be assigned to exactly one cabinet from the cabinet domain
1 = {cabinetTOthing(C, T) : cabinetDomain(C)} :- thing(T).

% A cabinet can contain a maximum of 5 things
:- 6 <= #count { T : cabinetTOthing(C, T), thing(T) }, cabinet(C).

% Each cabinet must be assigned to exactly one room from the room domain
1 = {roomTOcabinet(R, C) : roomDomain(R)} :- cabinet(C).

% A room can contain a maximum of 4 cabinets
:- 5 <= #count { C : roomTOcabinet(R, C), cabinetDomain(C) }, room(R).

% Define person-to-room assignment if a person owns a thing stored in a cabinet within that room
personTOroom(P, R) :- personTOthing(P, T), cabinetTOthing(C, T), roomTOcabinet(R, C).

% Define legacy person-to-room assignment based on legacy configurations
legacyConfig(personTOroom(P, R)) :- legacyConfig(personTOthing(P, T)), legacyConfig(cabinetTOthing(C, T)), legacyConfig(roomTOcabinet(R, C)).

% Ensure that cabinets are not shared between different owners for things within them
:- cabinetTOthing(C, T1), cabinetTOthing(C, T2),
   personTOthing(P1, T1), personTOthing(P2, T2), P1 < P2.

% Ensure that a room is assigned to only one person
:- personTOroom(P1, R), personTOroom(P2, R), P1 < P2.

% Define rooms and cabinets based on their usage in the configuration
room(R) :- roomTOcabinet(R, C).
room(R) :- personTOroom(P, R).
cabinet(C) :- cabinetTOthing(C, T).
cabinet(C) :- roomTOcabinet(R, C).

% Define persons and things from legacy configuration
person(P) :- legacyConfig(person(P)).
thing(T) :- legacyConfig(thing(T)).
personTOthing(P, T) :- legacyConfig(personTOthing(P, T)).

% Define things as either long or short
thing(T) :- thingLong(T).
thing(T) :- thingShort(T).
thingShort(T) :- thing(T), not thingLong(T).
:- thingLong(T), thingShort(T).

% Each cabinet must be either high or small, and high cabinets hold long things
1 = {cabinetHigh(C); cabinetSmall(C)} :- cabinet(C).
cabinetHigh(C) :- thingLong(T), cabinetTOthing(C, T).

% Assign size to cabinets based on type (high or small)
cabinetSize(C, 1) :- cabinet(C), cabinetSmall(C).
cabinetSize(C, 2) :- cabinet(C), cabinetHigh(C).

% Calculate room-to-cabinet size occupancy based on cabinet size
roomTOcabinetSize(R, C, S) :- roomTOcabinet(R, C), cabinetSize(C, S).

% A room can hold a maximum of 4 size units from its cabinets
:- 5 <= #sum { S, C : roomTOcabinetSize(R, C, S), cabinetDomain(C) }, room(R).

% Cost definitions for creating new items
cost(create(room(X)), W) :- room(X), roomCost(W).
cost(create(personTOroom(X, Y)), W) :- personTOroom(X, Y), personTOroomCost(W).
cost(create(cabinetHigh(X)), W) :- cabinetHigh(X), cabinetHighCost(W), cabinetDomainNew(X).
cost(create(cabinetSmall(X)), W) :- cabinetSmall(X), cabinetSmallCost(W), cabinetDomainNew(X).

% Reuse or delete choice for legacy configuration elements
1 { reuse(cabinet(X)); delete(cabinet(X)) } 1 :- legacyConfig(cabinet(X)).
1 { reuse(room(X)); delete(room(X)) } 1 :- legacyConfig(room(X)).
1 { reuse(thing(X)); delete(thing(X)) } 1 :- legacyConfig(thing(X)).
1 { reuse(person(X)); delete(person(X)) } 1 :- legacyConfig(person(X)).
1 { reuse(cabinetTOthing(C, T)); delete(cabinetTOthing(C, T)) } 1 :- legacyConfig(cabinetTOthing(C, T)).
1 { reuse(roomTOcabinet(R, C)); delete(roomTOcabinet(R, C)) } 1 :- legacyConfig(roomTOcabinet(R, C)).
1 { reuse(personTOroom(P, R)); delete(personTOroom(P, R)) } 1 :- legacyConfig(personTOroom(P, R)).

% Define presence of elements based on reuse or delete choice
cabinet(X) :- reuse(cabinet(X)).
:- cabinet(X), delete(cabinet(X)).

room(X) :- reuse(room(X)).
:- room(X), delete(room(X)).

thing(X) :- reuse(thing(X)).
:- thing(X), delete(thing(X)).

person(X) :- reuse(person(X)).
:- person(X), delete(person(X)).

cabinetTOthing(C, T) :- reuse(cabinetTOthing(C, T)).
:- cabinetTOthing(C, T), delete(cabinetTOthing(C, T)).

roomTOcabinet(R, C) :- reuse(roomTOcabinet(R, C)).
:- roomTOcabinet(R, C), delete(roomTOcabinet(R, C)).

personTOroom(P, R) :- reuse(personTOroom(P, R)).
:- personTOroom(P, R), delete(personTOroom(P, R)).

% Define cost for reusing elements from legacy configuration
cost(reuse(cabinetTOthing(C, T)), W) :- reuse(cabinetTOthing(C, T)), reuseCabinetTOthingCost(W).
cost(reuse(roomTOcabinet(R, C)), W) :- reuse(roomTOcabinet(R, C)), reuseRoomTOcabinetCost(W).
cost(reuse(personTOroom(P, R)), W) :- reuse(personTOroom(P, R)), reusePersonTOroomCost(W).
cost(reuse(cabinet(X)), W) :- reuse(cabinet(X)), cabinetSmall(X), reuseCabinetAsSmallCost(W).
cost(reuse(cabinet(X)), W) :- reuse(cabinet(X)), cabinetHigh(X), reuseCabinetAsHighCost(W).
cost(reuse(room(X)), W) :- reuse(room(X)), reuseRoomCost(W).

% Define cost for deleting elements from legacy configuration
cost(remove(cabinetTOthing(C, T)), W) :- delete(cabinetTOthing(C, T)), removeCabinetTOthingCost(W).
cost(remove(roomTOcabinet(R, C)), W) :- delete(roomTOcabinet(R, C)), removeRoomTOcabinetCost(W).
cost(remove(personTOroom(P, R)), W) :- delete(personTOroom(P, R)), removePersonTOroomCost(W).
cost(remove(cabinet(X)), W) :- delete(cabinet(X)), removeCabinetCost(W).
cost(remove(room(X)), W) :- delete(room(X)), removeRoomCost(W).

% Minimize total costs
#minimize { W : cost(_, W) }.

% Display selected information
#show cabinet/1.
#show cabinetHigh/1.
#show cabinetSmall/1.
#show room/1.
#show cabinetTOthing/2.
#show roomTOcabinet/2.
