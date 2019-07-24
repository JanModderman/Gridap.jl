module GridsTests

using Test
using Gridap
using Gridap.CellValuesGallery
using Gridap.Grids: GridFromData

c2v = [[1,2,4,5],[2,3,5,6]]
v2x = Point{2,Float64}[(0.,0.),(0.,1.),(0.,2.),(1.,0.),(1.,1.),(1.,2.)]

c2v = CellValueFromArray(c2v)
v2x = CellValueFromArray(v2x)

l = length(c2v)
order = 1
t = (HEX_AXIS,HEX_AXIS)
c2t = ConstantCellValue(t,l)
c2o = ConstantCellValue(order,l)

grid = GridFromData(v2x,c2v,c2t,c2o)

test_grid(grid,6,2)

end # module
