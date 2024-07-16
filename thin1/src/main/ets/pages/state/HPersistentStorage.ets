/**
 * PersistentStorage：持久化存储UI状态
 *
 * PersistentStorage将选定的AppStorage属性保留在设备磁盘上。应用程序通过API，以决定哪些AppStorage属性
 * 应借助PersistentStorage持久化。UI和业务逻辑不直接访问PersistentStorage中的属性，所有属性访问都是对
 * AppStorage的访问，AppStorage中的更改会自动同步到PersistentStorage。
 *
 * PersistentStorage和AppStorage中的属性建立双向同步。应用开发通常通过AppStorage访问PersistentStorage，
 * 另外还有一些接口可以用于管理持久化属性，但是业务逻辑始终是通过AppStorage获取和设置属性的。
 *
 *
 * PersistentStorage允许的类型和值有：
 * 1. number, string, boolean, enum 等简单类型。
 * 2. 可以被JSON.stringify()和JSON.parse()重构的对象，以及对象的属性方法不支持持久化。
 * 3. 支持Map类型，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值。且更新的值被持久化存储。
 * 4. 支持Set类型，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值。且更新的值被持久化存储。
 * 5. 支持Date类型，可以观察到Date整体的赋值。且更新的值被持久化存储。
 * 6. 支持undefined 和 null。支持联合类型。
 *
 *
 * PersistentStorage不允许的类型和值有：
 * 不支持嵌套对象（对象数组，对象的属性是对象等）。因为目前框架无法检测AppStorage中嵌套对象（包括数组）值的变化，
 * 所以无法写回到PersistentStorage中。
 *
 * 持久化数据是一个相对缓慢的操作，应用程序应避免以下情况：
 * 1. 持久化大型数据集。
 * 2. 持久化经常变化的变量。
 *
 * PersistentStorage的持久化变量最好是小于2kb的数据，不要大量的数据持久化，因为PersistentStorage写入磁盘的操作是同步的，
 * 大量的数据本地化读写会同步在UI线程中执行，影响UI渲染性能。如果开发者需要存储大量的数据，建议使用数据库api。
 *
 * PersistentStorage和UI实例相关联，持久化操作需要在UI实例初始化成功后
 * （即loadContent传入的回调被调用时）才可以被调用，早于该时机调用会导致持久化失败。
 *
 */



/**
 * 新应用安装后首次启动运行：
 * 1. 调用persistProp初始化PersistentStorage，首先查询在PersistentStorage本地文件中是否存在“aProp”，
 * 查询结果为不存在，因为应用是第一次安装。
 * 2. 接着查询属性“aProp”在AppStorage中是否存在，依旧不存在。
 * 3. 在AppStorge中创建名为“aProp”的number类型属性，属性初始值是定义的默认值47。
 * 4. PersistentStorage将属性“aProp”和值47写入磁盘，AppStorage中“aProp”对应的值和其后续的更改将被持久化。
 * 5. 在HPersistentStorage组件中创建状态变量@StorageLink('aProp') aProp，和AppStorage中“aProp”双向绑定，
 * 在创建的过程中会在AppStorage中查找，成功找到“aProp”，所以使用其在AppStorage找到的值47。
 *
 * 触发点击事件后：
 * 1. 状态变量@StorageLink('aProp') aProp改变，触发Text组件重新刷新。
 * 2. @StorageLink装饰的变量是和AppStorage中建立双向同步的，所以@StorageLink('aProp') aProp的变化会被同步回AppStorage中。
 * 3. AppStorage中“aProp”属性的改变会同步到所有绑定该“aProp”的单向或者双向变量。
 * 4. 因为“aProp”对应的属性已经被持久化，所以在AppStorage中“aProp”的改变会触发PersistentStorage，将新的改变写入本地磁盘。
 *
 * 后续启动应用：
 * 1. 执行PersistentStorage.persistProp('aProp', 47)，在首先查询在PersistentStorage本地文件查询“aProp”属性，成功查询到。
 * 2. 将在PersistentStorage查询到的值写入AppStorage中。
 * 3. 在HPersistentStorage组件里，@StorageLink绑定的“aProp”为PersistentStorage写入AppStorage中的值，即为上一次退出应用存入的值。
 *
 *
 * 在PersistentStorage之前访问AppStorage中的属性
 * 为反例。在调用PersistentStorage.persistProp或者persistProps之前使用接口访问AppStorage中的属性是错误的，
 * 因为这样的调用顺序会丢失上一次应用程序运行中的属性值。
 *
 */
PersistentStorage.persistProp('aProp', 47);
AppStorage.get<number>('aProp')

@Entry
@Component
struct HPersistentStorage {
  @StorageLink('aProp') aProp: number = 48;

  build() {
    // 应用退出时会保存当前结果。重新启动后，会显示上一次的保存结果
    Text(`${this.aProp}`)
      .onClick(() => {
        this.aProp += 1
      })

  }
}