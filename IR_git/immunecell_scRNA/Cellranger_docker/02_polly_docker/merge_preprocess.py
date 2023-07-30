#!/usr/bin/env python
# coding: utf-8

# In[1]:


import scanpy as sc
import scirpy as ir
import matplotlib.pyplot as plt
import os

# In[ ]:

value=os.environ["value"]
print("Value "+value)
adata = sc.read_10x_h5('./cellrangercount/'+value+'/outs/filtered_feature_bc_matrix.h5')


# In[ ]:


vdj =ir.io.read_10x_vdj('./cellrangervdj/'+value+'/outs/all_contig_annotations.csv')


# In[ ]:


ir.pp.merge_with_ir(adata, vdj)


# In[ ]:


adata.write('./merge/mergedadata')


# In[ ]:


sc.pp.filter_genes(adata, min_cells=10)
sc.pp.filter_cells(adata, min_genes=100)


# In[ ]:


sc.pp.normalize_per_cell(adata, counts_per_cell_after=1000)
sc.pp.log1p(adata)
sc.pp.highly_variable_genes(adata, flavor="cell_ranger", n_top_genes=5000)
sc.tl.pca(adata)

sc.pp.neighbors(adata)
sc.tl.umap(adata)
sc.tl.leiden(adata)


# In[ ]:


sc.pl.umap (adata, color ='leiden')
plt.savefig('./merge/umap.png')

# In[ ]:


ir.tl.chain_qc(adata)


# In[ ]:


ax = ir.pl.group_abundance(adata, groupby="receptor_subtype")


# In[ ]:


plt.savefig('./merge/receptor_subtype.png')


# In[ ]:


ax = ir.pl.group_abundance(adata, groupby="chain_pairing")


# In[ ]:


plt.savefig('./merge/chain_pairing.png')


# In[ ]:




