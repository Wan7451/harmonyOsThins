/**
 *  LocalStorage：页面级UI状态存储
 *
 *  LocalStorage是页面级的UI状态存储，通过@Entry装饰器接收的参数可以在页面内共享同一个LocalStorage实例。
 *  LocalStorage支持UIAbility实例内多个页面间状态共享。
 *
 *  LocalStorage是ArkTS为构建页面级别状态变量提供存储的内存内“数据库”。
 *
 *  1. 应用程序可以创建多个LocalStorage实例，LocalStorage实例可以在页面内共享，也可以通过GetShared接口，
 *      实现跨页面、UIAbility实例内共享。
 *  2. 组件树的根节点，即被@Entry装饰的@Component，可以被分配一个LocalStorage实例，
 *      此组件的所有子组件实例将自动获得对该LocalStorage实例的访问权限。
 *  3. 被@Component装饰的组件最多可以访问一个LocalStorage实例和AppStorage，
 *      未被@Entry装饰的组件不可被独立分配LocalStorage实例，只能接受父组件通过@Entry传递来的LocalStorage实例。
 *      一个LocalStorage实例在组件树上可以被分配给多个组件。
 *  4. LocalStorage中的所有属性都是可变的。
 *
 *
 * 应用程序决定LocalStorage对象的生命周期。当应用释放最后一个指向LocalStorage的引用时，比如销毁最后一个自定义组件，
 * LocalStorage将被JS Engine垃圾回收。
 *
 * LocalStorage根据与@Component装饰的组件的同步类型不同，提供了两个装饰器：
 * 1. @LocalStorageProp：@LocalStorageProp装饰的变量与LocalStorage中给定属性建立单向同步关系。
 * 2. @LocalStorageLink：@LocalStorageLink装饰的变量与LocalStorage中给定属性建立双向同步关系。
 *
 * LocalStorage创建后，命名属性的类型不可更改。后续调用Set时必须使用相同类型的值。
 * LocalStorage是页面级存储，getShared接口仅能获取当前Stage通过windowStage.loadContent传入的LocalStorage实例，
 * 否则返回undefined。
 *
 *
 *
 * 当自定义组件初始化的时候，@LocalStorageProp(key)/@LocalStorageLink(key)装饰的变量会通过给定的key，绑定LocalStorage对应的属性，
 * 完成初始化。本地初始化是必要的，因为无法保证LocalStorage一定存在给定的key。
 *
 * @LocalStorageProp
 *
 * @LocalStorageProp(key)是和LocalStorage中key对应的属性建立单向数据同步，ArkUI框架支持修改@LocalStorageProp(key)在本地的值，
 * 但是对本地值的修改不会同步回LocalStorage中。相反，如果LocalStorage中key对应的属性值发生改变，
 * 例如通过set接口对LocalStorage中的值进行修改，改变会同步给@LocalStorageProp(key)，并覆盖掉本地的值。
 *
 * 装饰器参数          key：常量字符串，必填（字符串需要有引号）。
 * 允许装饰的变量类型    Object、class、string、number、boolean、enum类型，以及这些类型的数组。
 *                    支持Map、Set、Date类型。
 *                    类型必须被指定，建议和LocalStorage中对应属性类型相同，否则会发生类型隐式转换，从而导致应用行为异常。
 *                    不支持any，支持undefined和null的联合类型。
 * 同步类型            单向同步：从LocalStorage的对应属性到组件的状态变量。组件本地的修改是允许的，
 *                    但是LocalStorage中给定的属性一旦发生变化，将覆盖本地的修改。
 * 被装饰变量的初始值    必须指定，如果LocalStorage实例中不存在属性，则用该初始值初始化该属性，并存入LocalStorage中。
 *
 * 从父节点初始化和更新  禁止，@LocalStorageProp不支持从父节点初始化，只能从LocalStorage中key对应的属性初始化，
 *                    如果没有对应key的话，将使用本地默认值初始化。
 * 初始化子节点         支持，可用于初始化@State、@Link、@Prop、@Provide。
 * 是否支持组件外访问    否。
 *
 *
 *
 * 观察变化
 *
 * 当装饰的数据类型为boolean、string、number类型时，可以观察到数值的变化。
 * 当装饰的数据类型为class或者Object时，可以观察到对象整体赋值和对象属性变化
 * 当装饰的对象是array时，可以观察到数组添加、删除、更新数组单元的变化。
 * 当装饰的对象是Date时，可以观察到Date整体的赋值，
 * 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值。
 * 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值。
 *
 *
 *
 * 框架行为
 *
 * 被@LocalStorageProp装饰的变量的值的变化不会同步回LocalStorage里。
 * @LocalStorageProp装饰的变量变化会使当前自定义组件中关联的组件刷新。
 * LocalStorage(key)中值的变化会引发所有被@LocalStorageProp对应key装饰的变量的变化，会覆盖@LocalStorageProp本地的改变。
 *
 *
 *
 * @LocalStorageLink
 *
 * @LocalStorageLink(key)是和LocalStorage中key对应的属性建立双向数据同步：
 * 1. 本地修改发生，该修改会被写回LocalStorage中；
 * 2. LocalStorage中的修改发生后，该修改会被同步到所有绑定LocalStorage对应key的属性上，
 *    包括单向（@LocalStorageProp和通过prop创建的单向绑定变量）、双向（@LocalStorageLink和通过link创建的双向绑定变量）变量。
 *
 * 装饰器参数           key：常量字符串，必填（字符串需要有引号）。
 * 允许装饰的变量类型    Object、class、string、number、boolean、enum类型，以及这些类型的数组。
 *                    支持Map、Set、Date类型。
 *                    类型必须被指定，建议和LocalStorage中对应属性类型相同，否则会发生类型隐式转换，从而导致应用行为异常。
 *                    不支持any,支持undefined和null的联合类型。
 * 同步类型            双向同步：从LocalStorage的对应属性到自定义组件，从自定义组件到LocalStorage对应属性。
 * 被装饰变量的初始值    必须指定，如果LocalStorage实例中不存在属性，则用该初始值初始化该属性，并存入LocalStorage中。
 *
 * 从父节点初始化和更新  禁止，@LocalStorageLink不支持从父节点初始化，只能从LocalStorage中key对应的属性初始化，
 *                    如果没有对应key的话，将使用本地默认值初始化。
 * 初始化子节点         支持，可用于初始化@State、@Link、@Prop、@Provide。
 * 是否支持组件外访问    否。
 *
 *
 * 观察变化
 *
 * 当装饰的数据类型为boolean、string、number类型时，可以观察到数值的变化。
 * 当装饰的数据类型为class或者Object时，可以观察到对象整体赋值和对象属性变化。
 * 当装饰的对象是array时，可以观察到数组添加、删除、更新数组单元的变化。
 * 当装饰的对象是Date时，可以观察到Date整体的赋值。
 * 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值。
 * 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值。
 *
 *
 * 框架行为
 * 1. 当@LocalStorageLink(key)装饰的数值改变被观察到时，修改将被同步回LocalStorage对应属性键值key的属性中。
 * 2. LocalStorage中属性键值key对应的数据一旦改变，属性键值key绑定的所有的数据
 *    （包括双向@LocalStorageLink和单向@LocalStorageProp）都将同步修改。
 * 3. 当@LocalStorageLink(key)装饰的数据本身是状态变量，它的改变不仅仅会同步回LocalStorage中，还会引起所属的自定义组件的重新渲染。
 *
 *
 *
 *
 *
 * 自定义组件支持接收LocalStorage实例。
 *
 * 当自定义组件作为子节点，定义了成员属性时，LocalStorage实例必须要放在第二个参数位置传递，否则会报类型不匹配的编译问题。
 * 当在自定义组件中定义了属性时，暂时不支持只有一个LocalStorage实例作为入参。如果没定义属性，可以只传入一个LocalStorage实例作为入参。
 * 如果定义的属性不需要从父组件初始化变量，则第一个参数需要传{}。
 * 作为构造参数传给子组件的LocalStorage实例在初始化时就会被决定，
 * 可以通过@LocalStorageLink或者LocalStorage的API修改LocalStorage实例中保存的属性值，但LocalStorage实例自身不能被动态修改。
 */
import { common, Want } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';

class FPropB {
  code: number

  constructor(code: number) {
    this.code = code
  }
}

let para: Record<string, number> = { 'PropA': 47 };
let storage: LocalStorage = new LocalStorage(para);
storage.setOrCreate('PropB', new FPropB(50));


@Entry(storage)
@Component
struct FLocalStorage {
  private context = getContext(this) as common.UIAbilityContext

  build() {
    Column() {
      Button("LocalStorage")
        .onClick(() => {
          //saveLocalStorage()

          let want: Want = {
            deviceId: "", // deviceId为空表示本设备
            bundleName: "com.example.myapplication",
            abilityName: "Thin2Ability",
            moduleName: "thin1", //moduleName在待启动的UIAbility属于不同的Module时添加
            parameters: {
              instanceKey: "aaaa",
              extraKey: "bbbbb"
            }
          }
          this.context.startAbility(want)

          // router.pushUrl({
          //   url: "pages/state/FLocalStorage2"
          // })

        })
      FParent()
      FChild()
    }
  }
}


@Component
struct FParent {
  @LocalStorageLink('PrapA') childCode: number = 1
  @LocalStorageLink('PropB') childProp: FPropB = new FPropB(0)

  build() {
    Column() {
      Button(`Parent ${this.childCode}`)
        .onClick(() => {
          this.childCode += 1
        })
      Button(`Parent object ${this.childProp.code}`)
        .onClick(() => {
          this.childProp.code += 1;
        })
    }
  }
}


@Component
struct FChild {
  @LocalStorageLink('PrapA') childCode: number = 1
  @LocalStorageProp('PropB') childProp: FPropB = new FPropB(0)

  build() {
    Column() {

      Button(`child ${this.childCode}`)
        .onClick(() => {
          this.childCode += 1
        })
      Button(`child object ${this.childProp.code}`)
        .onClick(() => {
          this.childProp.code += 1;
        })
    }
  }
}


function saveLocalStorage() {

  let para: Record<string, number> = { "PropA": 47 };
  let storage = new LocalStorage(para)

  let link1: SubscribedAbstractProperty<number> = storage.link('PropA')
  let prop: SubscribedAbstractProperty<number> = storage.prop('PropA')
  link1.set(48)
  console.log(`currA is ${storage.get("PropA")}`)
  console.log(`currB is ${storage.get("PropB")}`)
  prop.set(1)
  console.log(`currA is ${storage.get("PropA")}`)

  //key 需要提前定义，不然就报错
  let link2: SubscribedAbstractProperty<number> = storage.setAndLink("PropB", 10)
  link2.set(49)
  console.log(`currA is ${storage.get("PropA")}`)
  console.log(`currB is ${storage.get("PropB")}`)
}




















