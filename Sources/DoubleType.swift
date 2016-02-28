internal protocol DoubleType
{
    var double: Double { get }

    init(double: Double)
}

extension Int: DoubleType
{
    internal var double: Double { return Double(self) }

    init(double: Double)
    {
        self = Int(double)
    }
}

extension Float: DoubleType
{
    internal var double: Double { return Double(self) }

    internal init(double: Double)
    {
        self = Float(double)
    }
}

extension Double: DoubleType
{
    internal var double: Double { return self }

    internal init(double: Double)
    {
        self = double
    }
}
