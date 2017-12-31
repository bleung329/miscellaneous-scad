// filamentary: a0.8,b0.7,g0.01,n100,r30
// pretty: 0.8,0.8,0.01
// very nice and classical: 0.8,0.8,0.002,n100,r30, also n20, n50 is very nice
// b0.7 is nice, too
// elegant 1.6,0.7,.002
alpha = 0.8;
beta = 0.7;
gamma = 0.002;

hexSize = 10;
// If you use join mode, it is recommended you set filledRatio to 0.5 or less.
joinMode = 0; // [0:no, 1:yes]
// How much of the hex to fill.
filledFraction = 1;
steps = 90;
thickness = 2;
radius = 40;

module dummy(){}

animate = 0;

cos30 = cos(30);
sin30 = sin(30);

// The data holds about 1/12 of the snowflake.
function rowSize(i) =
    i == 0 ? 1 : ceil((i+1)/2);

data = [for (i=[0:radius]) [for(j=[0:rowSize(i)-1]) i==0 ? 1 : beta]];

// This allows data to be got at points at one
// remove from the data by using symmetries.
function get(data,i,j) = 
    i == -1 ? data[1][0] :
    i > radius ? beta :
    i <= 1 ? data[i][0] :
    let(rs = rowSize(i)) (
    j == -1 ? data[i][1] :
    j == rs ? ( i%2 ? data[i][rs-1] : data[i][rs-2] )
    : data[i][j] );    
    
function receptive(data,i,j) =
    get(data,i,j)>=1 || (
    j == 0 ? get(data,i,1)>=1 || get(data,i+1,0)>=1 || get(data,i+1,1)>=1 || get(data,i-1,0)>=1 :
    get(data,i,j-1)>=1 || get(data,i,j+1)>=1 || get(data,i+1,j)>=1 || get(data,i+1,j+1)>=1 || get(data,i-1,j)>=1 || get(data,i-1,j-1)>=1);
    
function u(data,i,j) = 
    receptive(data,i,j) ? 0 : get(data,i,j);
    
function neighborUSum(data,i,j) =
    j == 0 ? 2*u(data,i,1)+u(data,i+1,0)+2*u(data,i+1,1)+u(data,i-1,0) :
    u(data,i,j-1)+u(data,i,j+1)+u(data,i+1,j)+u(data,i+1,j+1)+u(data,i-1,j)+u(data,i-1,j-1);

/*function evolveCell(data,i,j) =
    let(r=receptive(data,i,j))
        (r ? gamma : 0) + get(data,i,j) + (alpha/12)*(-6*u(data,i,j)+neighborUSum(data,i,j));
*/

function evolveCell(data,i,j) =
        (receptive(data,i,j) ? gamma+get(data,i,j) : (1-alpha/2)*get(data,i,j)) + (alpha/12)*neighborUSum(data,i,j);
    
function evolve(data, n) = 
    n == 0 ? data :
    evolve(
     [ for(i=[0:radius]) 
        [ for(j=[0:rowSize(i)-1]) 
            evolveCell(data,i,j) ] ], n-1);

function getCoordinates(i,j) = 
        hexSize*([0,i]+[cos(30),-sin(30)]*j);

module show(i,j) {
    foldout() 
    translate(getCoordinates(i,j)) circle(r=1.001*hexSize/sqrt(3)*filledFraction,$fn=6);
}

module visualize(data) {
    for(i=[0:len(data)-1]) for(j=[0:rowSize(i)-1]) 
        if(data[i][j]>=1) linear_extrude(height=(data[i][j]-1)*40) show(i,j);
}    

module visualizeJoined(data) {
    for(i=[0:len(data)-1]) for(j=[0:rowSize(i)-1])
        if(data[i][j]) {
           if(get(data,i,j+1))
                hull() { show(i,j); show(i,j+1); }
           if(get(data,i+1,j))
                hull() { show(i,j); show(i+1,j); }
           if (get(data,i+1,j+1))
                hull() { show(i,j); show(i+1,j+1); }
        }
}    

module foldout() {
    for(i=[0:60:359.999]) rotate(i) {
        mirror([1,0]) children();
        children();
    }
}

if (animate) {
    foldout() visualize(evolve(data,round($t*steps)));
}
else {
//    linear_extrude(height=thickness)
        if (joinMode)
            visualizeJoined(evolve(data,steps));
        else
            visualize(evolve(data,steps));
}

//echo(evolveCell(data,1,0));
//echo(receptive(data,3,0));
//echo(neighborCount(data,3,0));