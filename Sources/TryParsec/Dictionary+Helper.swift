/// Missing helper.
internal func toDict<Key: Hashable, Value>(_ tuples: [(Key, Value)]) -> [Key : Value]
{
    var dict = [Key : Value]()
    for tuple in tuples {
        dict[tuple.0] = tuple.1
    }
    return dict
}
