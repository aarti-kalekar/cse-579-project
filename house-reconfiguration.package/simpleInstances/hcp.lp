% Define constraints for HCP
% Each thing must be stored in exactly one cabinet
1 { cabinetTOthing(C,T) : cabinetDomainNew(C) } 1 :- thing(T).

% Each cabinet must be in exactly one room
1 { roomTOcabinet(R,C) : roomDomainNew(R) } 1 :- cabinetDomainNew(C).

% A cabinet can contain at most 5 things
:- cabinet(C), 6 {cabinetTOthing(C,T) : thing(T)}.

% A room can contain at most 4 cabinets
:- room(R), 5 {roomTOcabinet(R, C) : cabinet(C)}.

% A room may only contain cabinets storing things owned by the room's occupant
roomTOPerson(R,P) :- personTOthing(P,T), cabinetTOthing(C,T), roomTOcabinet(R,C).
legacyConfig(roomTOPerson(R,P)) :- legacyConfig(personTOthing(P,T)), legacyConfig(cabinetTOthing(C,T)), legacyConfig(roomTOcabinet(R,C)).

% Each room belongs to exactly one person
:- roomTOPerson(R,P1), roomTOPerson(R,P2), P1 != P2.

person(P) :- legacyConfig(person(P)).
thing(T) :- legacyConfig(thing(T)).
personTOthing(P,T) :- legacyConfig(personTOthing(P,T)).

#show cabinetTOthing/2.
#show roomTOcabinet/2.
