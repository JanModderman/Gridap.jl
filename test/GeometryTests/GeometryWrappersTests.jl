module GeometryWrappersTests

using Gridap
using UnstructuredGrids: RefCell, UGrid
using Test

# Polytope to UnstructuredGrid

t = HEX_AXIS
polytope = Polytope((t,t,t))

grid = Grid(polytope,2)
#writevtk(grid,"grid")

trian = Triangulation(grid)
quad = CellQuadrature(trian,order=2)

q = coordinates(quad)
phi = CellGeomap(trian)
x = evaluate(phi,q)

#writevtk(x,"x")

# Polytope to RefCell

t = HEX_AXIS
polytope = Polytope((t,t,t))

refcell = RefCell(polytope)

# UnstructuredGrid to UGrid

c2v = [[1,2,4,5],[2,3,5,6]]
v2x = Point{2,Float64}[(0.,0.),(0.,1.),(0.,2.),(1.,0.),(1.,1.),(1.,2.)]
l = length(c2v)
order = 1
t = (HEX_AXIS,HEX_AXIS)
c2t = ConstantCellValue(t,l)
c2o = ConstantCellValue(order,l)
c2v_data, c2v_ptrs = generate_data_and_ptrs(c2v)

grid = UnstructuredGrid(v2x,c2v_data,c2v_ptrs,c2t,c2o)
ugrid = UGrid(grid)

graph = FullGridGraph(grid)
test_full_grid_graph(graph,2)

t = TET_AXIS
polytope = Polytope((t,t,t))

grid = Grid(polytope,2)

end # module

