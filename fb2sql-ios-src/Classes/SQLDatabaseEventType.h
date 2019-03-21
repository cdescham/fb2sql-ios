//
//  SQLDatabaseEventType.h
//  Pods
//
//  Created by Christophe Deschamps on 06/03/2019.
//

#ifndef SQLDatabaseEventType_h
#define SQLDatabaseEventType_h


typedef NS_ENUM(NSInteger, SQLDatabaseEventType) {
    /// A new child node is added to a location.
    SQLDatabaseEventTypeChildAdded,
    /// A child node is removed from a location.
    SQLDatabaseEventTypeChildRemoved,
    /// A child node at a location changes.
    SQLDatabaseEventTypeChildChanged,
    /// A child node moves relative to the other child nodes at a location.
    SQLDatabaseEventTypeChildMoved,
    /// Any data changes at a location or, recursively, at any child node.
    SQLDatabaseEventTypeValue
} NS_SWIFT_NAME(SQLDatabaseEventType);

#endif /* SQLDatabaseEventType_h */
