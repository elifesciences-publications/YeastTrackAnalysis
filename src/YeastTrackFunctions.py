# by Joh Schoeneberg 2018

from scipy import stats
import numpy as np

def findInflectionPoint(x,y):
    # this function calculates the point where the function has a kink and returns the index of that point
    slope, intercept, r, prob2, see = stats.linregress(x, y)
    mx = x.mean()
    sx2 = ((x-mx)**2).sum()
    sd_intercept = see * np.sqrt(1./len(x) + mx*mx/sx2)
    sd_slope = see * np.sqrt(1./sx2)

    inter_slope_intercept = [slope,sd_slope,intercept,sd_intercept]
    #print("slope={}±{}, intercept={}±{}, r={}, prob2={}, see={}".format(slope,sd_slope, intercept,sd_intercept, r, prob2, see))

    #plt.plot(x, y, 'o', label='original data',color='b')
    #plt.plot(x, intercept + slope*x, 'r', label='fitted line')
    #plt.show()

# find the inflection point

    newy = y-(intercept+slope*x)
    #newy = np.array(newy)
    #inflectionPoint = np.min(newy)
    inflectionPointIndex = np.argmin(newy)
    return(inflectionPointIndex)
