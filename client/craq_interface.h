using namespace std;

typedef callback<void, string>::ref cbstr;
typedef callback<void, bool>::ref cbbool;
typedef enum { READ, WRITE } ev_t;
typedef map<ID_Value, Node>::iterator ring_iter;

#define MAX_BUF = 2000

class chain_meta {
  public:
    unsigned int chain_size;
    vector<string> data_centers;
};

class craq_interface {
  static void watcher_wrapper(string path, void* context, CLOSURE); 

  public:
    craq_interface();
    ~craq_interface();
    void init(string zoo_list, bool strong, cbbool cb, CLOSURE);

    void set_key(string key, string val, cbstr cb, CLOSURE);
    void get_key(string key, cbstr cb, CLOSURE);

  private:
    ring_iter ring_succ(ID_Value id);
    void ring_incr(ring_iter * it);
    void connect_to_manager(string node_list, cbbool cb, CLOSURE);
    void populate_node_list(cbbool cb, CLOSURE);
    void node_list_watcher(string path, CLOSURE);
    void get_chain_info(ID_Value chain_id, 
      ptr<callback<void, ptr<chain_meta> > > cb, CLOSURE);
    bool zoo_connected;
    bool ring_init;
    bool strong_consistency;
    string datacenter;
    map<ID_Value, chain_meta> chain_meta_list;
   map<ID_Value, Node> ring;
};

