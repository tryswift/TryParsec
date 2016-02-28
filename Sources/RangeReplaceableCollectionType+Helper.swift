extension RangeReplaceableCollectionType
{
    /// Missing initializer.
    public init(_ x: Self.Generator.Element)
    {
        self.init()
        self.append(x)
    }

#if !SWIFT_PACKAGE
//#if swift(>=2.2)
//#else
    /// Missing initializer until Swift 2.1.
    public init<S: SequenceType where S.Generator.Element == Self.Generator.Element>(_ xs: S)
    {
        self.init()
        self.appendContentsOf(xs)
    }
#endif
}
