from pandas import pandas as pd
import numpy as np
from matplotlib import pyplot as plt

# This next line makes our charts show up in the notebook
# %matplotlib inline

table = pd.read_csv("./powerOutage.csv")
# table.head()
# plt.bar(x=np.arange(1, 21), height=table['Duration'])
plt.bar(x=np.arange(1, 355), height=table['Duration'])

# # Give it a title
plt.title("UPSi failover chart")

# # Give the x axis some labels across the tick marks.
# # Argument one is the position for each label
# # Argument two is the label values and the final one is to rotate our labels
plt.xticks(np.arange(1, 355), table['Label'], rotation=45)

# # Give the x and y axes a title
plt.xlabel("Dates")
plt.ylabel("Duration")

# # Finally, show me our new plot
plt.show()
