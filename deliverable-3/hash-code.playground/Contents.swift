var hashids = Hashids(salt:"this is my salt");
var hash = hashids.encode(1, 2, 3);
var values = hashids.decode(s!);
