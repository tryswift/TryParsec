import TryParsec

extension Reply
{
    var _done: (input: In, output: Out)?
    {
        switch self {
            case let .Done(input, output):
                return (input, output)
            default:
                return nil
        }
    }

    var _fail: (input: In, contexts: [String], message: String)?
    {
        switch self {
            case let .Fail(input, contexts, message):
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
    var decompose: (head: Generator.Element, tail: [Generator.Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}

/// e.g. `between(0, [1, 2, 3]) = [[0, 1, 2, 3], [1, 0, 2, 3], [1, 2, 0, 3], [1, 2, 3, 0]]`.
func between<T>(x: T, _ ys: [T]) -> [[T]]
{
    if let (head, tail) = ys.decompose {
        return [[x] + ys] + between(x, tail).map { (val: [T]) -> [T] in [head] + val } // explict type-annotation is needed for faster type-inference
    }
    else {
        return [[x]]
    }
}

func permutations<T>(xs: [T]) -> [[T]]
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
