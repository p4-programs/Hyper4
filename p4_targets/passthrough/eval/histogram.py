"""
Plot historgram(s) for passthrough tests.

Relied on example at http://matplotlib.org/examples/statistics/histogram_demo_features.html

David Hancock
Univ of Utah
"""
import numpy as np
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt

# Get data
x = np.loadtxt("./passthroughx1/ping", dtype='int')
mu = np.mean(x)
sigma = np.std(x)

y = np.loadtxt("./passthroughx2/ping", dtype='int')


num_bins = 5
#n, bins, patches = plt.hist(x, num_bins, normed=1, facecolor='green', alpha=0.5)
plt.hist(x, num_bins, normed=1, histtype='stepfilled', facecolor='red', alpha=0.5)
plt.hist(y, num_bins, normed=1, histtype='stepfilled', facecolor='blue', alpha=0.5)
#y = mlab.normpdf(bins, mu, sigma)
#plt.plot(bins, y, 'r--')
plt.xlabel('RTT(ms)')
plt.ylabel('%')
plt.title(r'Histogram of Ping RTT: Single Passthrough')

plt.subplots_adjust(left=0.15)
plt.show()