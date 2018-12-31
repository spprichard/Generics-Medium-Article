import Foundation

//Article: https://medium.com/swift2go/mastering-generics-with-protocols-the-specification-pattern-5e2e303af4ca

//MARK: Version 1
enum Size {
    case small
    case meidum
    case large
}

protocol Sized {
    var size: Size {get set}
}


enum Color {
    case red
    case green
    case blue
}

protocol Colored {
    var color: Color {get set}
}


struct Product {
    var name: String
    var color: Color
    var size: Size
}

extension Product: CustomStringConvertible  {
    var description: String {
        return "\(size) \(color) \(name)"
    }
}
extension Product: Colored, Sized {}

struct ProductFilter {
    static func filterProducts(_ products: [Product], by size: Size) -> [Product] {
        var output = [Product]()
        
        for product in products where product.size == size {
            output.append(product)
        }
        
        return output
    }

}

//MARK: Use Case
let tree = Product(name: "tree", color: .green, size: .large)
let frog = Product(name: "frog", color: .green, size: .small)
let strawberry = Product(name: "strawberry", color: .red, size: .small)


let result = ProductFilter.filterProducts([tree, frog, strawberry], by: .small)
print(result)



//MARK: Version 2 - Protocols
protocol Specification {
    associatedtype T
    
    func isSatisfied(item: T) -> Bool
}

struct ColorSpec<T: Colored>: Specification {
    var color: Color
    
    func isSatisfied(item: T) -> Bool {
        return item.color == color
    }
}

struct SizeSpec<T: Sized>: Specification {
    var size: Size
    
    func isSatisfied(item: T) -> Bool {
        return item.size == size
    }
}


protocol Filter {
    associatedtype T
    
    func filter<Spec: Specification>(items: [T], specs: Spec) -> [T] where Spec.T == T
}

struct GenericProductFilter<T>: Filter {
    func filter<Spec: Specification>(items: [T], specs spec: Spec) -> [T] where T == Spec.T {
        var output = [T]()
        
        for item in items {
            if spec.isSatisfied(item: item) {
                output.append(item)
            }
        }
        
        return output
    }
}

let small = SizeSpec<Product>(size: .small)
let gResult = GenericProductFilter().filter(items: [tree, frog, strawberry], specs: small)
print("Generic Solution: \(gResult)")


//MARK: Recursive specification

struct AndSpec<T, SpecA: Specification, SpecB: Specification> : Specification where T == SpecA.T, SpecA.T == SpecB.T {
    var specA: SpecA
    var specB: SpecB
    
    init(specA: SpecA, specB: SpecB) {
        self.specA = specA
        self.specB = specB
    }
    
    func isSatisfied(item: T) -> Bool {
        return specA.isSatisfied(item: item) && specB.isSatisfied(item: item)
    }
}

//MARK: Use Case
let redSpec = ColorSpec<Product>(color: .red)
let smallSpec = SizeSpec<Product>(size: .small)
let specs = AndSpec(specA: redSpec, specB: smallSpec)

let multipleSpecResult = GenericProductFilter().filter(items: [tree, frog, strawberry], specs: specs)
print("Multiple Spec Result: \(multipleSpecResult)")
