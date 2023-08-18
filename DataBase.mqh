
template<typename T>
class QueryResult{
private:
    int count;    
public:
    T result[];
    bool succeed;
    QueryResult():succeed(false),count(0){};

    void ShowResult(){ArrayPrint(result);};
    void SetSize(int n){count=n; ArrayResize(result,count);};
    void AddSize(int n){count+=n; ArrayResize(result,count);};
    void SubSize(int n){count-=n;ArrayResize(result,count);};
    int GetSize(){return count;};
};

template<typename T, typename Q>
class DataBase  
{
private:
    int db; 
public:
    DataBase(int _db){ db=_db;};
    DataBase(string filename);
    DataBase();
    ~DataBase(){DatabaseClose(db);};

    int getDB(){ return db;};
    void setDB(int _db){ db=_db;};
    void TransactionStart(){DatabaseTransactionBegin(db);};
    void TransactionRollback(){DatabaseTransactionRollback(db);};
    void TransactionCommit(){DatabaseTransactionCommit(db);};
    bool Execute(string sqlStr, T &[]);
    bool Execute(string sqlStr);
    bool Query(string sqlStr, T &[], QueryResult<Q> *p);
    bool Query(string sqlStr, QueryResult<Q> *p);
};

template<typename T>
string MakeSqlString(string sqlStr, T &arr[]){
    string splits[];
    StringSplit(sqlStr,StringGetCharacter("?",0),splits);
    int n=ArraySize(splits)-1;
    string result=splits[0];
    for(int i=0;i<n;i++){
        result+=string(arr[i])+splits[i+1];
    }
    return result;
}

template<typename T, typename Q>
void DataBase::DataBase(string filename)
{
    db=DatabaseOpen(filename, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE | DATABASE_OPEN_COMMON); 
    if(db==INVALID_HANDLE) 
    { 
        Print("DB: ", filename, " open failed with code ", GetLastError()); 
        return; 
    } 
}

template<typename T, typename Q>
void DataBase::DataBase()
{
    db=DatabaseOpen(NULL, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE | DATABASE_OPEN_MEMORY); 
    if(db==INVALID_HANDLE) 
    { 
        Print("DB in memory open failed with code ", GetLastError()); 
        return; 
    } 
}

template<typename T, typename Q>
bool DataBase::Execute(string sqlStr, T &arr[]){
    sqlStr = MakeSqlString(sqlStr, arr);
    if(!DatabaseExecute(db, sqlStr))
    { 
        Print(sqlStr);
        Print("DB: fillng the table failed with code ", GetLastError()); 
        return false; 
    } 
    return true;
}

template<typename T, typename Q>
bool DataBase::Execute(string sqlStr){
    if(!DatabaseExecute(db, sqlStr))
    { 
        Print(sqlStr);
        Print("DB: fillng the table failed with code ", GetLastError()); 
        return false; 
    } 
    return true;
}

template<typename T, typename Q>
bool DataBase::Query(string sqlStr, T &arr[], QueryResult<Q> *p){
    sqlStr = MakeSqlString(sqlStr, arr);
    int request=DatabasePrepare(db, sqlStr); 
    p.SetSize(0);
    if(request!=INVALID_HANDLE) 
    {
        p.AddSize(1);
        while(DatabaseReadBind(request, p.result[p.GetSize()-1])) 
        { 
            p.AddSize(1);
        } 
        p.SubSize(1); 
        p.succeed=true;
    }else{
        p.succeed=false;
        Print(sqlStr);
        Print("Query request failed with code ", GetLastError()); 
    }    
   DatabaseFinalize(request); 
   return p.succeed;
}

template<typename T, typename Q>
bool DataBase::Query(string sqlStr, QueryResult<Q> *p){
    int request=DatabasePrepare(db, sqlStr); 
    p.SetSize(0);
    if(request!=INVALID_HANDLE) 
    {
        p.AddSize(1);
        while(DatabaseReadBind(request, p.result[p.GetSize()-1])) 
        { 
            p.AddSize(1);
        } 
        p.SubSize(1); 
        p.succeed=true;
    }else{
        p.succeed=false;
        Print(sqlStr);
        Print("Query request failed with code ", GetLastError()); 
    }    
   DatabaseFinalize(request); 
   return p.succeed;
}
