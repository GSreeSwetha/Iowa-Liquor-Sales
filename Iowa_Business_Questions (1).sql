-- Business Questions

-- Liquor Sales: Measures

-- 1. Sales$

Select ROUND(sum(Invoice_Sale_Dollars),2) AS Total_Sales from fct_iowa_liquor_sales_invoice_header;

-- 2.Sales volume (gallons)

Select ROUND(sum(Invoice_Volume_Sold__Gallons),2) AS Sales_volume_gallons from fct_iowa_liquor_sales_invoice_header;

-- Sales volume (bottles)

Select ROUND(sum(`Bottle_Volume__ml`)/3785.41,2) AS Bottle_volume_gallons from fct_iowa_liquor_sales_invoice_lineitem;

-- Gross profit (retail price – cost)

Select ROUND(sum((`State_Bottle_Retail` - `State_Bottle_Cost`) * Bottles_Sold), 2) AS Bottle_volume_gallons 
from fct_iowa_liquor_sales_invoice_lineitem;

-- Sales $ per Capita

Select YEAR(str_to_date(h.Invoice_Date, '%m/%d/%Y')) as Order_Date, y.City, ROUND(sum(h.Sale__Dollars)/y.population,2) AS Total_Sales
from fct_iowa_liquor_sales_invoice_header h, FCT_iowa_city_population_by_year y, Dim_Iowa_Liquor_Stores st
where h.Store_SK = st.Store_SK and st.City_SK = y.City_SK
Group BY Order_Date, y.City
Order By Order_Date, y.City;

-- Liquor Sales by Time

-- Total 

Select ROUND(sum(Invoice_Sale_Dollars),2) AS Total_Sales from fct_iowa_liquor_sales_invoice_header;

-- Year

Select YEAR(str_to_date(Invoice_Date, '%m/%d/%Y')) as Order_Date, ROUND(sum(Invoice_Sale_Dollars),2) AS Total_Sales
from fct_iowa_liquor_sales_invoice_header 
Group BY Order_Date
Order By Order_Date;

-- Year, Month

Select YEAR(str_to_date(Invoice_Date, '%m/%d/%Y')) as Order_Year, MONTHNAME(str_to_date(Invoice_Date, '%m/%d/%Y')) as Order_Month, ROUND(sum(Invoice_Sale_Dollars),2) AS Total_Sales
from fct_iowa_liquor_sales_invoice_header 
Group BY Order_Year, Order_Month
Order By Order_Year, Order_Month;


-- Year over Year (YOY)

/*Select Sale__Dollars, YEAR(str_to_date(Date, '%m/%d/%Y')) as Invoice_Date
from stg_iowa_liquor_sales
WHERE YEAR(str_to_date(Date, '%m/%d/%Y')) IN ('2021','2022');*/

Select YEAR(str_to_date(Invoice_Date, '%m/%d/%Y')) as Invoice_Date, ROUND(SUM(Invoice_Sale_Dollars),2) as Total_Sales,
ROUND(ROUND(SUM(Invoice_Sale_Dollars),2) - (lag(ROUND(SUM(Invoice_Sale_Dollars),2)) 
OVER (ORDER BY YEAR(str_to_date(Invoice_Date, '%m/%d/%Y')))),2)
AS YOY_Sales
from fct_iowa_liquor_sales_invoice_header
GROUP BY Invoice_Date
ORDER BY Invoice_Date;

-- Liquor sales by dimension

-- Store

Select st.Store_Name, ROUND(sum(h.Invoice_Sale_Dollars),2) AS Total_Sales
from fct_iowa_liquor_sales_invoice_header h, Dim_Iowa_Liquor_Stores st
WHERE h.Store_SK = st.Store_SK
GROUP BY st.Store_Name
Order BY st.Store_Name;
-- LIMIT 10000;

-- County

select ROUND(sum(h.Invoice_Sale_Dollars),2) AS Total_Sales, cp.County
from fct_iowa_liquor_sales_invoice_header h, Dim_iowa_county c, Dim_Iowa_Liquor_Stores st
where h.Store_SK = st.Store_SK and st.County_SK = c.County_SK
group by cp.County
order by cp.County;

-- City

select ROUND(sum(s.Sale__Dollars),2) AS Total_Sales, cp.City
from fct_iowa_liquor_sales_invoice_header h, Dim_iowa_city c, Dim_Iowa_Liquor_Stores st
where h.Store_SK = st.Store_SK and c.City_SK = st.City_SK
group by cp.City
order by cp.City;

-- Category

Select c.Category_Name, ROUND(sum(il.Sale_Dollars * il.Bottles_Sold),2) as Total_Sales
from Dim_iowa_liquor_Product_Categories c, Dim_iowa_liquor_Products p, fct_iowa_liquor_sales_invoice_lineitem il
where c.Category_SK = p.Category_SK and p.Item_SK = il.Item_SK
GROUP BY c.Category_Name
ORDER BY c.Category_Name;

-- Item
Select p.Item_Description, ROUND(sum(il.Sale_Dollars * il.Bottles_Sold),2) as Total_Sales
from Dim_iowa_liquor_Products p, fct_iowa_liquor_sales_invoice_lineitem il
where p.Item_SK = il.Item_SK
GROUP BY p.Item_Description
ORDER BY p.Item_Description;

-- Vendor
Select v.Vendor_Name, ROUND(sum(il.Sale_Dollars * il.Bottles_Sold),2) as Total_Sales
from Dim_iowa_liquor_Vendors v, Dim_iowa_liquor_Products p, fct_iowa_liquor_sales_invoice_lineitem il
where v.Vendor_SK = p.Vendor_SK and p.Item_SK = il.Item_SK
GROUP BY v.Vendor_Name
ORDER BY v.Vendor_Name;


-- Liquor sales by sales $ 

-- Yearly sales including 2022 YTD

Select ROUND(SUM(invoice_sale_dollars),2) as Total_Sales, YEAR(str_to_date(Invoice_Date, '%m/%d/%Y')) as Invoice_Date
from fct_iowa_liquor_sales_invoice_header
GROUP BY Invoice_Date
ORDER BY Invoice_Date;

-- Top 20 stores (all-time)

select Store_Name, Store_ID, ROUND(sum(h.Invoice_Sale_Dollars),2) as Total_Sales
from fct_iowa_liquor_sales_invoice_header h, Dim_Iowa_Liquor_Stores st
where h.Store_SK = st.Store_SK
GROUP BY Store_Name, Store_ID
order by Total_Sales
LIMIT 20;

-- Top 20 cities (all-time)

select dc.City, ROUND(sum(h.Invoice_Sale_Dollars),2) as Total_Sales
from fct_iowa_liquor_sales_invoice_header h, Dim_Iowa_Liquor_Stores st, Dim_iowa_city dc
where h.Store_SK = st.Store_SK and st.City_SK = dc.City_SK
GROUP BY dc.City
order by Total_Sales desc
LIMIT 20;

-- Top 10 counties (all-time)

select dc.County, ROUND(sum(h.Invoice_Sale_Dollars),2) as Total_Sales
from fct_iowa_liquor_sales_invoice_header h, Dim_Iowa_Liquor_Stores st, Dim_iowa_county dc
where h.Store_SK = st.Store_SK and st.County_SK = dc.County_SK
GROUP BY dc.County
order by Total_Sales desc
LIMIT 20;


-- Top 20 categories (all-time)

Select c.Category_Name, ROUND(sum(h.Invoice_Sale_Dollars),2) as Total_Sales
from Dim_iowa_liquor_Product_Categories c, Dim_iowa_liquor_Products p, fct_iowa_liquor_sales_invoice_lineitem h
where c.Category_SK = p.Category_SK and p.Item_SK = h.Item_SK
GROUP BY c.Category_Name
ORDER BY Total_Sales desc
LIMIT 20;


-- Top 50 items (all-time)

Select p.Item_Description, ROUND(sum(il.Sale_Dollars),2) as Total_Sales
from Dim_iowa_liquor_Products p, fct_iowa_liquor_sales_invoice_lineitem il
where p.Item_SK = il.Item_SK
GROUP BY p.Item_Description
ORDER BY Total_Sales DESC
LIMIT 50;


-- Top 20 vendor (all-time)

Select v.Vendor_Name, ROUND(sum(il.Sale_Dollars),2) as Total_Sales
from Dim_iowa_liquor_Vendors v, Dim_iowa_liquor_Products p, fct_iowa_liquor_sales_invoice_lineitem il
where v.Vendor_SK = p.Vendor_SK and p.Item_SK = il.Item_SK
GROUP BY v.Vendor_Name
ORDER BY Total_Sales desc
LIMIT 20;
