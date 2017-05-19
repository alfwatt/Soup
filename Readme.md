= Soup

A persistance framework modeled on the Apple Newton API

== Newton Soup

    http://en.m.wikipedia.org/wiki/Soup_(Apple_Newton)

    http://www.canicula.com/newton/prog/soups.htm

    Unlike traditional operating systems such as the MacOS and Windows NT there is no file system and therefore no files in the Newton Operating Sbtystem. Data is instead stored in opaque collections like a database in entities known as soups. Each entry in a soup can be likened to a record in a database and each data member in an entry (known as a slot) can be likened to a field in a database. Unlike database records entries in a soup do not all have to have the same slots. To retrieve data entries from the soups you don't access them directly but rather send queries to the soups which return cursor objects. You then use the cursor object to get copies of individual entries in the soup. You can then do whatever you want with the copies. The original entries in the soups are not modified unless you overwrite them with your changed copy.

    The actual soups themselves are held on the Newton in stores. Every Newton device has at least one store (the internal store) but they can also have other external stores on PCMCIA cards. On a Newton MessagePad 130 there can be one external store as there is one PCMCIA slot. Other devices such as the MessagePad 2000 which has two PCMCIA slots can have more external stores. So that you don't have to worry about which store your soup is on you can use a type of soup known as a union soup in your application. This is a system maintained virtual soup that is made up of all entries from a particular named soup no matter where the entries are physically stored. For Example - if you have two soups named "Match Results" (one on the internal store and one on an external store) to hold results of football matches you can treat them as one big soup containing all the entries by using a union soup. Union soups take into account any choices you make for default storage location and add new entries to a union soup in the member soup which resides on your default store (see AddToDefaultStoreXmit below).


== Soup Objects

== Soup Usage