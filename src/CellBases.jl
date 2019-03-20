export CellBasis
export evaluate

"""
T is for the type of value
D is for the dimension of the domain
"""
abstract type CellBasis{D,T} end

evaluate(::CellBasis{D,T} where {D,T} ,::CellPoints{D} where D)::CellBasisValues{T}= @abstractmethod

"""
Returns another CellBasis object that represents the gradient
TG is a value whose rank is one order grater than the one of T
"""
gradient(::CellBasis{D,T} where {D,T})::CellBasis{D,TG} = @abstractmethod

# Concrete implementations

"""
Concrete implementation for the case of the same interpolation on
all cells, but arbitrary sampling points in each cell. This is typically needed
for unfitted methods
"""
struct CellBasisValuesFromSingleInterpolation{T,D} <: CellBasisValues{T}
  basis::MultivariatePolynomialBasis{D,T}
  points::CellPoints{D}
end

Base.length(self::CellBasisValuesFromSingleInterpolation) = length(self.points)

function Base.iterate(self::CellBasisValuesFromSingleInterpolation{T,D}) where {T,D}
  maxpoints = maxlength(self.points)
  ndofs = length(self.basis)
  values = Array{T,2}(undef,(ndofs,maxpoints))
  pnext = iterate(self.points)
  state = (values,pnext)
  iterate(self,state)
end

function Base.iterate(self::CellBasisValuesFromSingleInterpolation,state)
  (values,pnext) = state
  if pnext == nothing
    nothing
  else
    (points,pstate) = pnext
    evaluate!(self.basis,points,values)
    vals = @view values[:,1:length(points)]
    pnext = iterate(self.points,pstate)
    state = (values,pnext)
    (vals, state)
  end
end

maxsize(self::CellBasisValuesFromSingleInterpolation) = (length(self.basis), maxlength(self.points))

"""
Concrete implementation for the case of the same interpolation
and the same sampling points on all cells
"""
struct ConstantCellBasisValues{D,T} <: IndexableCellArray{T,2}
  basis::MultivariatePolynomialBasis{D,T}
  points::Array{Point{D},1}
  l::Int
  values::Array{T,2}
end

function ConstantCellBasisValues(
  basis::MultivariatePolynomialBasis{D,T}, points::Array{Point{D},1}, l::Int) where {D,T}
  ndofs = length(basis)
  npoin = length(points)
  values = Array{T,2}(undef,(ndofs,npoin))
  evaluate!(basis,points,values)
  ConstantCellBasisValues(basis,points,l,values)
end

Base.length(self::ConstantCellBasisValues) = self.l

maxsize(self::ConstantCellBasisValues) = (length(self.basis),length(self.points))

Base.getindex(self::ConstantCellBasisValues,cell::Int) = self.values


struct CellBasisFromSingleInterpolation{D,T} <: CellBasis{D,T}
  basis::MultivariatePolynomialBasis{D,T}
end

function evaluate(
  self::CellBasisFromSingleInterpolation{D,T}, cellpoints::CellPoints{D}) where {D,T}
  if isa(cellpoints,ConstantCellArray)
    points = cellpoints.array
    l = length(cellpoints)
    ConstantCellBasisValues(self.basis,points,l)
  else
    CellBasisValuesFromSingleInterpolation(self.basis,cellpoints)
  end
end

function gradient(self::CellBasisFromSingleInterpolation)
  grad_basis = gradient(self.basis)
  CellBasisFromSingleInterpolation(grad_basis)
end
