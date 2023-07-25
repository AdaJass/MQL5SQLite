#include "DataBase.mqh"

struct AA
{
    int a;
    int b;
    double c;
};

struct BB
{
    int a;
    int b;
    double c;
};

void OnStart()
{
    MathSrand(TimeCurrent());
    DataBase<double, AA>db("test");
    DataBase<string, BB>db2(db.getDB());
    db.Execute("CREATE TABLE IF NOT EXISTS AA(a int PRIMARY key, b int, c double)");
    db.Execute("CREATE TABLE IF NOT EXISTS BB(d int PRIMARY key, e char(1), f double)");
    double toinsert[] = {MathRand(),2,3};
    string strinsert[] = {MathRand(),"c5","3"};
    db.TransactionStart();
    for(int i=0;i<100;i++){
        toinsert[0] = MathRand();
        if(!db.Execute("insert into AA(a,b,c) values (?,?,?)", toinsert)){
            db.TransactionRollback();
        }
    } 
    db.TransactionCommit();   
    db2.Execute("insert into BB(d,e,f) values (?,?,?)", strinsert);
    QueryResult<AA> *p1 = db.Query("select * from AA where c=3");
    QueryResult<BB> *p2 = db2.Query("select * from BB where f=3");
    p1.ShowResult();
    Print("len of AA result: ",p1.GetSize());
    p2.ShowResult();
    Print("len of BB result: ",p2.GetSize());
    delete p1;
    delete p2;
    
}
