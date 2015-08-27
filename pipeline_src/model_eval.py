import matplotlib as mpl
# The line below is to allow png creation without having to run X Server
mpl.use("Agg")
import matplotlib.pyplot as plt
from sklearn import linear_model, ensemble, svm, metrics, preprocessing
from sklearn.metrics import precision_recall_curve
from sklearn.metrics import average_precision_score
from sklearn import metrics
import datetime
import numpy as np
from os.path import basename, dirname
from data_loader import connect_to_db
import kappa as k

def scale_scores(scores):
    s_min = scores.min()
    s_max = scores.max()
    scores = (scores - s_min) / float(s_max - s_min)
    return scores


def make_confusion_mat(exp, thresh, save_file):
    if exp.has_prob == False and exp.y_test_pred_prob is not None: 
        y_prob_scaled = scale_scores(exp.y_test_pred_prob)
        y_pred = [val >= thresh for val in y_prob_scaled]
    elif exp.has_prob == True: 
        y_pred = [val >= thresh for val in exp.y_test_pred_prob]
    else:
        y_pred = exp.y_test_pred

    plt.clf()
    labels = [1, 0]
    label_titles = ["abandoned", "inhabited"]
    cm = metrics.confusion_matrix(exp.y_test, y_pred, labels)
    #Compute Kappa metric
    kappa_val = k.kappa(cm)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    cax = ax.matshow(cm, cmap=plt.cm.Blues)

    ax.text(-0.25, 0, "{}".format(cm[0][0]), fontsize=14)
    ax.text(0.75, 0, "{}".format(cm[0][1]), fontsize=14)
    ax.text(-0.25, 1, "{}".format(cm[1][0]), fontsize=14)
    ax.text(0.75, 1, "{}".format(cm[1][1]), fontsize=14)

    plt.title('Confusion matrix @ thresh = {} | Kappa = {} ({})'.format(thresh, kappa_val[0], kappa_val[1]))
    fig.colorbar(cax)
    ax.set_xticklabels([''] + label_titles)
    ax.set_yticklabels([''] + label_titles)
    plt.xlabel('Predicted')
    plt.ylabel('True')
    plt.savefig(save_file)


def make_multiple_conf_mats(exp, thresh_list, save_file_dir='.', save_file_base='model_test'):
    cm_file_list = []

    for thresh in thresh_list:
        thresh_str = str(thresh).replace('.', '_')
        cfm_file_name = save_file_dir + "/" + save_file_base + "_Confusion_Mat_{}.png".format(thresh_str)

        make_confusion_mat(exp, thresh, cfm_file_name)
        cm_file_list.append(cfm_file_name)

    return cm_file_list


def save_to_sql(exp, model):
    model_name = str(model).split("(")[0]

    model_params = model.get_params()
    model_param_string = '('
    for key in model_params:
        model_param_string += '{} : {}, '.format(key, model_params[key])
    model_param_string += ')'
    
    fpr, tpr, roc_thresh = metrics.roc_curve(exp.y_test, exp.y_test_pred_prob) 
    roc_auc = metrics.auc(fpr, tpr)

    avg_prec = metrics.average_precision_score(exp.y_test, exp.y_test_pred_prob)

    train_score = model.score(exp.x_train, exp.y_train)

    key_thresholds = [0.01, 0.025, 0.05, 0.10, 0.20, 0.25, 0.33, 0.5, 0.66, 0.75, 0.80, 0.90, 0.95, .975, 0.99] 
    precisions_at_thresh = []
    recall_at_thresh = []
    accuracy_at_thresh = []
    kappa_at_thresh = []

    for threshold in key_thresholds:
        y_pred_at_thresh = [val >= threshold for val in exp.y_test_pred_prob]
        prec = metrics.precision_score(exp.y_test, y_pred_at_thresh)
        acc = metrics.accuracy_score(exp.y_test, y_pred_at_thresh)
        recall = metrics.recall_score(exp.y_test, y_pred_at_thresh)
        kappa_val = k.kappa(metrics.confusion_matrix(exp.y_test, y_pred_at_thresh))[0]
        precisions_at_thresh.append(prec)
        recall_at_thresh.append(recall)
        accuracy_at_thresh.append(acc)
        kappa_at_thresh.append(kappa_val)

    feature_list = exp.get_features()
    feature_list = map(str, feature_list)
    feature_list_str = ', '.join(feature_list)

    feature_importance_str = ""

    try:
        for tup in sorted(zip(feature_list, model.feature_importances_), 
                      key= lambda x: x[1])[::-1]: 
            feature_importance_str += "({}, {}), ".format(tup[0], tup[1])
    except AttributeError:
        print "Model has no feature_importances."

    try:
        model_coeffs = model.coef_[0]
        for tup in sorted(zip(feature_list, model_coeffs), 
                      key= lambda x: x[1])[::-1]: 
            feature_importance_str += "({}, {}), ".format(tup[0], tup[1])
    except AttributeError:
        print "Model has no feature coefficients, evaluating without."


    scaled_features_str = ', '.join([str(key) for key in exp.preprocessor.scalers])

    sql_columns_str = "(model_name, parameter_dict, train_start, train_end, train_size, test_start, test_end, test_size, num_cols, subample_percent, y_var, model_eval_doc, train_score, auc, avg_precision, feature_list, featue_importances, scaled_features, prec_at_1, prec_at_2_5 , prec_at_5, prec_at_10, prec_at_20, prec_at_25, prec_at_33, prec_at_50, prec_at_66, prec_at_75, prec_at_80, prec_at_90, prec_at_95, prec_at_97_5, prec_at_99, acc_at_1, acc_at_2_5, acc_at_5, acc_at_10, acc_at_20, acc_at_25, acc_at_33, acc_at_50, acc_at_66, acc_at_75, acc_at_80, acc_at_90, acc_at_95, acc_at_97_5 , acc_at_99, recall_at_1, recall_at_2_5, recall_at_5, recall_at_10, recall_at_20, recall_at_25, recall_at_33, recall_at_50, recall_at_66, recall_at_75, recall_at_80, recall_at_90, recall_at_95, recall_at_97_5 , recall_at_99, kappa_at_1, kappa_at_2_5, kappa_at_5, kappa_at_10, kappa_at_20, kappa_at_25, kappa_at_33, kappa_at_50, kappa_at_66, kappa_at_75, kappa_at_80, kappa_at_90, kappa_at_95, kappa_at_97_5 , kappa_at_99)"

    sql_values_str = (model_name, 
                      model_param_string, 
                      exp.train_range[0],
                      exp.train_range[1],
                      exp.x_train.shape[0],
                      exp.test_range[0],
                      exp.test_range[1],
                      exp.x_test.shape[0],
                      exp.x_train.shape[1],
                      exp.subsample_ratio,
                      exp.y_var,
                      exp.html_file,
                      train_score,
                      roc_auc,
                      avg_prec,
                      feature_list_str,
                      feature_importance_str,
                      scaled_features_str)

    for val in precisions_at_thresh:
        sql_values_str += (val, )

    for val in accuracy_at_thresh:
        sql_values_str += (val, )

    for val in recall_at_thresh:
        sql_values_str += (val, )

    for val in kappa_at_thresh:
        sql_values_str += (val, )


    sql_values_str = str(sql_values_str)
    sql_values_str = sql_values_str.replace('"','\'')

    sql_query = "INSERT INTO model_results {} VALUES {};".format(sql_columns_str, sql_values_str)

    print "Saving evaluation to sql table model_results."
    with connect_to_db() as conn:
        cur = conn.cursor()
        cur.execute(sql_query)
        conn.commit()
        cur.close()
    print "Saving complete."


def save_experiment_html(exp, model, save_file_name):
    """ Given a model, an experiment object, write_html evaluates the model 
    in whichever ways it can and prints the result to an html document as 
    specified by the save_file_name parameter.
    """

    # Get the parameters used in the model
    model_params = model.get_params()
    model_name = str(model).split("(")[0]
    time_suffix = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

    if save_file_name is not None:
        save_file_dir = dirname(save_file_name)
        file_base = basename(save_file_name).split(".")[0]
    else:
        save_file_dir= "."
        file_base = model_name
    
    file_base = "_".join([file_base, time_suffix])

    html_file = save_file_dir + "/" + file_base + ".html"
    print "Writing evaluation html document for {}".format(model_name)

    img_file_list = []

    roc_curve_file = save_file_dir + "/" + file_base + "_ROC_Curve.png"
    pr_curve_file = save_file_dir + "/" + file_base + "_PR_Curve.png"
    pr_curve_file_n = save_file_dir + "/" + file_base + "_PR_Curve_n.png"

    img_file_list.append(roc_curve_file)
    img_file_list.append(pr_curve_file)
    img_file_list.append(pr_curve_file_n)

    fpr, tpr, roc_thresh = metrics.roc_curve(exp.y_test, exp.y_test_pred_prob) 
    roc_auc = metrics.auc(fpr, tpr)

    plt.clf()
    plt.title('Receiver Operating Characteristic')
    plt.plot(fpr, tpr, 'b', label='AUC = %0.2f'% roc_auc)
    plt.legend(loc='lower right')
    plt.plot([0,1],[0,1],'r--')
    plt.xlim([0,1.0])
    plt.ylim([0,1.0])
    plt.ylabel('True Positive Rate')
    plt.xlabel('False Positive Rate')
    plt.savefig(roc_curve_file)
    
    precision_curve, recall_curve, pr_thresholds = metrics.precision_recall_curve(exp.y_test, exp.y_test_pred_prob, pos_label=True)

    precision_curve = precision_curve[:-1]
    recall_curve = recall_curve[:-1]
    pct_above_per_thresh = []
    number_scored = len(exp.y_test_pred_prob)

    exp.y_test_pred_prob = np.array(exp.y_test_pred_prob)
    num_th = pr_thresholds.shape[0]
    if num_th > 5000:
        skip_size = int(num_th/1000.0)
        plotting_thresholds = pr_thresholds[0::skip_size]
        plotting_prec = precision_curve[0::skip_size]
        plotting_recall = recall_curve[0::skip_size]
    else:
        plotting_thresholds = pr_thresholds
        plotting_prec = precision_curve
        plotting_recall = recall_curve

    for value in plotting_thresholds:
        num_above_thresh = exp.y_test_pred_prob[exp.y_test_pred_prob>=value].shape[0]
        pct_above_thresh = num_above_thresh / float(number_scored)
        pct_above_per_thresh.append(pct_above_thresh)
    pct_above_per_thresh = np.array(pct_above_per_thresh)

    plt.clf()
    fig, ax1 = plt.subplots()
    ax1.plot(pct_above_per_thresh, plotting_prec, 'b')
    ax1.set_xlabel('Percent of All Loans')
    ax1.set_ylabel('Percision', color='b')
    ax2 = ax1.twinx()
    ax2.plot(pct_above_per_thresh, plotting_recall, 'r')
    ax2.set_ylabel('Recall', color='r')
    name = model_name
    plt.title('Precision-Recall')
    plt.savefig(pr_curve_file_n)

    plt.clf()
    plt.plot(recall_curve, precision_curve, label='Precision-Recall curve')
    plt.xlabel('Recall (TP / (TP + FN))')
    plt.ylabel('Precision (TP / (TP + FP))')
    plt.ylim([0.0, 1.05])
    plt.xlim([0.0, 1.0])
    plt.title('Precision-Recall')
    plt.legend(loc="lower left")
    plt.savefig(pr_curve_file)

    cfm_files = make_multiple_conf_mats(exp, [0.1, 0.25, 0.5, 0.75, 0.9], save_file_dir, file_base)
    img_file_list = img_file_list + cfm_files

    save_file = open(html_file, 'w')
    save_file.write("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n")
    save_file.write("<html lang=\"en\">\n")
    save_file.write("<head>\n")
    save_file.write("<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">\n")
    save_file.write("<h1>Model Evaluation Sheet</h1>\n")
    save_file.write("</head>\n")
    save_file.write("<body>\n")
    save_file.write("<h2>Classifier: {}</h2><br>".format(model_name))
    save_file.write("Training Data Range: {} to {}<br>".format(exp.train_range[0], exp.train_range[1]))
    save_file.write("Testing Data Range: {} to {}<br>".format(exp.test_range[0], exp.test_range[1]))
    save_file.write("<br>Model AUC: {}<br>".format(roc_auc))
    save_file.write("-"*100 + "<br>")

    for elem in model_params:
        save_file.write("{}: {}<br>".format(elem, model_params[elem]))
    save_file.write("-"*100 + "<br>")
    
    for file_name in img_file_list:
        save_file.write("<IMG SRC=\"{}\"></IMG>\n<br></br>".format(basename(file_name)))
   
    feature_list = map(str, exp.get_features())

    if (model_name == "RandomForestClassifier"
        or model_name == "DecisionTreeClassifier"
        or model_name == "AdaBoostClassifier"
        or model_name == "GradientBoostingClassifier"):                    
        save_file.write("<h3>Feature Importances:</h3>\n<br>")
        for tup in sorted(zip(feature_list, model.feature_importances_), 
                          key= lambda x: x[1])[::-1]: 
            save_file.write("{}<br>".format(tup))
    
    if (model_name == "LinearSVC"
        or model_name == "SVC"):
        model_coeffs = model.coef_[0]
        save_file.write("<h3>Feature Coefficients:</h3>\n<br>")
        for tup in sorted(zip(feature_list, model_coeffs), 
                          key= lambda x: x[1])[::-1]: 
            save_file.write("{}<br>".format(tup))
    
    save_file.write("</body></html>")
    save_file.close()
    print "Evaluation document written to {}".format(html_file)
    return html_file
