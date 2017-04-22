## 2017同济大学数学建模
## 基于非参拟合的ATM交易模型的状态特征分析与异常检测
## 数据预处理
* 响应时间在第 2 9 13 周均出现持续波动的异常数据。因此将这些数据的影响剔除。![](https://i.imgur.com/T955HLt.png)
* 成功率的极值数据偏离平均水平不是太多。因此不做剔除处理，保留所有原数据。![](https://i.imgur.com/CK1Wjr5.png)

## 非参数密度估计法——核密度估计
* 经验分布函数估计：![](https://i.imgur.com/qViHmwh.png)
* 检验模型： ![](https://i.imgur.com/embtie0.png)

## 特征值提取
* 业务量  
![](https://i.imgur.com/GKl1Guj.png)
* 响应时间  
![](https://i.imgur.com/CHlpUbS.png)
* 成功率 
![](https://i.imgur.com/cRLsZ3c.png)

## 模型改进——基于聚类的特征值进一步校验
* 聚类过后每个分组的样本空间成倍增大，带宽可以取更小的值，这意味着可以提高核密度估计法的准确性。