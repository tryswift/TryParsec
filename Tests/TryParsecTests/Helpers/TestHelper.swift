import TryParsec

extension Reply
{
    var _done: (input: In, output: Out)?
    {
        switch self {
            case let .done(input, output):
                return (input, output)
            default:
                return nil
        }
    }

    var _fail: (input: In, contexts: [String], message: String)?
    {
        switch self {
            case let .fail(input, contexts, message):
                return (input, contexts, message)
            default:
                return nil
        }
    }
}

typealias USV = String.UnicodeScalarView

// MARK: Helpers

// From https://www.objc.io/blog/2014/10/06/functional-snippet-1-decomposing-arrays/

extension Array
{
    var decompose: (head: Iterator.Element, tail: [Iterator.Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}

/// e.g. `between(0, [1, 2, 3]) = [[0, 1, 2, 3], [1, 0, 2, 3], [1, 2, 0, 3], [1, 2, 3, 0]]`.
func between<T>(_ x: T, _ ys: [T]) -> [[T]]
{
    if let (head, tail) = ys.decompose {
        return [[x] + ys] + between(x, tail).map { (val: [T]) -> [T] in [head] + val } // explict type-annotation is needed for faster type-inference
    }
    else {
        return [[x]]
    }
}

func permutations<T>(_ xs: [T]) -> [[T]]
{
    if let (head, tail) = xs.decompose {
        return permutations(tail).flatMap { permTail in
            between(head, permTail)
        }
    }
    else {
        return [[]]
    }
}

extension Result
{
    var value: Success?
    {
        guard case let .success(value) = self else { return nil }
        return value
    }

    var error: Failure?
    {
        guard case let .failure(value) = self else { return nil }
        return value
    }
}
